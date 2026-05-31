# Signal flow and architecture (v2)

Production-ready Mermaid diagrams for wiki and technical docs. All flows match
`vendor/core/bin/monitor-engine.sh`, `vendor/core/lib/*.sh`, and shipped adapters
as of core **2.0.0**.

**Sources:** [`vendor/core/CONTRACT.md`](../../../vendor/core/CONTRACT.md),
[`vendor/core/lib/diagnosis.sh`](../../../vendor/core/lib/diagnosis.sh),
[`vendor/core/lib/checks.sh`](../../../vendor/core/lib/checks.sh),
[`Public/docs/architecture.md`](../architecture.md).

---

## 1. System context (two vantage points)

```mermaid
flowchart TB
    subgraph Remote["Remote site"]
        RLAN["REMOTE_LAN_IP<br/>(LAN gateway over tunnel)"]
        RWAN["REMOTE_WAN_IP<br/>(public IP)"]
        RDDNS["REMOTE_DDNS hostname"]
    end

    subgraph Local["Local site"]
        subgraph GWMon["Gateway role — adapter"]
            GWE["monitor-engine.sh<br/>--role gateway"]
            GWState["state file<br/>N:UP / N:DOWN"]
        end
        subgraph LANMon["LAN client role"]
            LCE["monitor-engine.sh<br/>--role lan_client"]
            JSON["state.json v2"]
        end
        VPN["Site-to-site VPN<br/>(IPsec / OpenVPN / other — transport agnostic)"]
    end

  Internet((Internet<br/>1.1.1.1 probe))

    GWE -->|ping| RLAN
    GWE -->|ping| RWAN
    LCE -->|ping| RLAN
    LCE -->|ping| RWAN
    LCE -->|dig @1.1.1.1| RDDNS
    LCE -->|ping| Internet
    GWE --> VPN
    LCE --> VPN
    GWE --> GWState
    LCE -->|SSH read state line| GWState
    LCE --> JSON

    SMTP[(SMTP)]
    NC[Notification Center / stub]
    UI[SwiftBar / Tunnel Monitor.app / tray]

    GWE --> SMTP
    LCE --> SMTP
    LCE --> NC
    JSON -. read only .-> UI
```

**Note:** The engine does not call vendor VPN APIs. Reachability is inferred from
ICMP and DNS only. VPN daemon health on the gateway is optional via adapter
`hooks/diagnostics.sh` (email appendix only).

---

## 2. Core engine module graph

```mermaid
flowchart LR
    ENG["monitor-engine.sh"]
    ENG --> common["lib/common.sh"]
    ENG --> checks["lib/checks.sh"]
    ENG --> diag["lib/diagnosis.sh"]
    ENG --> dedup["lib/dedup.sh"]
    ENG --> sj["lib/state-json.sh"]
    ENG --> sl["lib/state-line.sh"]
    ENG --> email["lib/email-body.sh"]

    subgraph Hooks["Adapter hooks (optional)"]
        H1["hooks/diagnostics.sh"]
        H2["hooks/post_alert.sh"]
    end

    ENG --> Hooks
```

| Module | Responsibility |
|--------|----------------|
| `checks.sh` | `tm_run_health_checks` — ping `REMOTE_LAN_IP`, `REMOTE_WAN_IP`, `1.1.1.1`; resolve `REMOTE_DDNS` |
| `diagnosis.sh` | `tm_compute_diagnosis` — canonical decision tree |
| `dedup.sh` | `tm_query_gateway_dedup` — SSH → gateway `state` line |
| `state-line.sh` | Gateway `N:UP` / `N:DOWN` read/write |
| `state-json.sh` | LAN `state.json` atomic write (schema v2) |

---

## 3. Health check signal path (every cycle)

```mermaid
flowchart TD
    START([Scheduler invokes check]) --> LOAD[Load config.env]
    LOAD --> HC[tm_run_health_checks]

    HC --> P1{ping REMOTE_LAN_IP}
    P1 -->|ok| T_OK[tunnel_ok = true]
    P1 -->|fail| T_NO[tunnel_ok = false]

    HC --> P2{ping REMOTE_WAN_IP}
    P2 --> W_OK[wan_ok]
    P2 --> W_NO[wan_ok = false]

    HC --> P3{ping 1.1.1.1}
    P3 --> O_OK[our_ok]
    P3 --> O_NO[our_ok = false]

    HC --> D1[dig REMOTE_DDNS @1.1.1.1]
    D1 --> D2{resolved == REMOTE_WAN_IP?}
    D2 -->|yes| DNS_OK[dns_match = true]
    D2 -->|no| DNS_NO[dns_match = false]

    T_OK --> ROLE{role?}
    T_NO --> ROLE
    W_OK --> ROLE
    W_NO --> ROLE
    O_OK --> ROLE
    O_NO --> ROLE
    DNS_OK --> ROLE
    DNS_NO --> ROLE

    ROLE -->|lan_client| DEDUP[tm_query_gateway_dedup SSH]
    ROLE -->|gateway| GWLOGIC[Gateway state machine]
    DEDUP --> DIAG[tm_compute_diagnosis]
    DIAG --> LANSM[LAN alert / recovery / state.json]
    GWLOGIC --> GWOUT[Gateway email + state line]
```

**Platform note:** macOS uses `ping -W` in milliseconds; Linux uses seconds
(`vendor/core/lib/checks.sh`).

---

## 4. LAN client — full check cycle (sequence)

```mermaid
sequenceDiagram
    participant SCH as launchd / systemd
    participant ENG as monitor-engine.sh
    participant CFG as config.env
    participant NET as Network
    participant SSH as ssh-gateway-state.sh
    participant GW as Gateway state file
    participant HOOK as adapter diagnostics.sh
    participant SMTP as send-email.sh
    participant NTF as notify.sh
    participant FS as state.json

    SCH->>ENG: check cycle
    ENG->>CFG: tm_load_config
    ENG->>NET: ping REMOTE_LAN_IP
    ENG->>NET: ping REMOTE_WAN_IP
    ENG->>NET: ping 1.1.1.1
    ENG->>NET: dig REMOTE_DDNS
    ENG->>SSH: tm_query_gateway_dedup
    SSH->>GW: ssh cat state file
    GW-->>SSH: state line UP or DOWN
    SSH-->>ENG: gateway reachable and state
    ENG->>ENG: tm_compute_diagnosis
    alt HEALTHY and was DOWN
        ENG->>SMTP: recovery email
        ENG->>NTF: banner RECOVERED
    else failure at threshold and was UP
        ENG->>HOOK: diagnostics hook optional
        HOOK-->>ENG: email appendix text
        alt dedup suppresses email
            ENG->>NTF: banner DOWN only
        else
            ENG->>SMTP: alert email
            ENG->>NTF: banner DOWN
        end
        ENG->>ENG: alert_state DOWN
    else counting or OUR_INTERNET_DOWN
        Note over ENG: log only counter rules apply
    end
    ENG->>FS: atomic write state.json
    ENG-->>SCH: exit 0
```

---

## 5. Gateway role — check cycle (sequence)

Gateway logic is **simpler** than LAN: no full diagnosis enum; inline text for
DDNS drift and remote WAN down (`tm_gateway_check` in `monitor-engine.sh`).

```mermaid
sequenceDiagram
    participant SCH as systemd timer
    participant ENG as monitor-engine.sh
    participant NET as Network
    participant HOOK as diagnostics-ipsec.sh (UniFi)
    participant SMTP as send-email.sh
    participant ST as state line file

    SCH->>ENG: check gateway role
    ENG->>ST: read state line
    ENG->>NET: ping REMOTE_LAN_IP
    ENG->>NET: ping REMOTE_WAN_IP
    alt tunnel ping ok
        alt was DOWN
            ENG->>HOOK: diagnostics recovery
            ENG->>SMTP: RECOVERED email
        end
        ENG->>ST: write UP zero count
    else tunnel ping fail
        ENG->>ENG: increment fail count
        alt count at threshold and alert UP
            ENG->>ENG: classify diagnosis text
            ENG->>HOOK: diagnostics alert
            ENG->>SMTP: DOWN email
            ENG->>ST: write DOWN state
        else still counting
            ENG->>ST: write UP counting
        end
    end
    ENG-->>SCH: exit 0
```

---

## 6. LAN client diagnosis decision tree

First match wins (`tm_compute_diagnosis`).

```mermaid
flowchart TD
    START([Health checks + gateway dedup done]) --> Q1{our_ok?<br/>ping 1.1.1.1}
    Q1 -- no --> OID["OUR_INTERNET_DOWN<br/>no alert; counter frozen"]:::muted
    Q1 -- yes --> Q2{tunnel_ok?}
    Q2 -- yes --> H["HEALTHY<br/>recovery if was DOWN"]:::ok
    Q2 -- no --> Q3{GATEWAY_REACHABLE?}
    Q3 -- no --> GU["GATEWAY_UNREACHABLE<br/>alert; no email suppress"]:::alert
    Q3 -- yes --> Q4{state == 0:UP?}
    Q4 -- yes --> DA["DISAGREEMENT<br/>alert; no suppress"]:::alert
    Q4 -- no --> Q5{dns_match?}
    Q5 -- no --> DD["DDNS_DRIFT"]:::alert
    Q5 -- yes --> Q6{wan_ok?}
    Q6 -- no --> RID["REMOTE_INTERNET_DOWN"]:::alert
    Q6 -- yes --> TD["TUNNEL_DOWN"]:::alert

    GU --> SUP{tm_should_suppress_email?}
    DA --> SUP
    DD --> SUP
    RID --> SUP
    TD --> SUP
    SUP -- gateway N:DOWN, not GU/DA --> SE["Suppress SMTP<br/>banner still fires"]:::dedup
    SUP -- else --> EM["Send SMTP alert"]:::alert

    classDef ok fill:#d4edda,stroke:#28a745
    classDef alert fill:#f8d7da,stroke:#dc3545
    classDef dedup fill:#fff3cd,stroke:#ffc107
    classDef muted fill:#e2e3e5,stroke:#6c757d
```

---

## 7. Email dedup branching (LAN client only)

```mermaid
flowchart TD
    A[Threshold crossed — tunnel down] --> B{diagnosis GATEWAY_UNREACHABLE<br/>or DISAGREEMENT?}
    B -- yes --> SEND[Send email]
    B -- no --> C{GATEWAY_REACHABLE<br/>and GATEWAY_ALERT=DOWN?}
    C -- yes --> SUP[Suppress email]
    C -- no --> SEND
    SUP --> BAN[notify.sh banner still runs]
    SEND --> BAN
```

---

## 8. Adapter hook propagation

```mermaid
flowchart LR
    ENG[monitor-engine.sh] --> RUN[tm_run_hook name]
    RUN --> A1{TM_ADAPTER_DIR/hooks/name?}
    A1 -- yes --> EXEC[bash hook]
    A1 -- no --> A2{INSTALL_ROOT/hooks/name?}
    A2 -- yes --> EXEC
    A2 -- no --> SKIP[no-op]

    subgraph UniFi["unifi-gateway adapter"]
        IPSEC[diagnostics-ipsec.sh<br/>ipsec statusall + journalctl]
    end

    subgraph Generic["generic-linux-gateway"]
        GEN[diagnostics.sh<br/>reachability summary only]
    end

    EXEC --> UniFi
    EXEC --> Generic
```

Installed via `--adapter-dir` on the thin `monitor.sh` wrapper.

---

## 9. UI read path (no active probing)

```mermaid
flowchart LR
    FS[state.json] --> SW[SwiftBar plugin]
    FS --> APP[Tunnel Monitor.app]
    FS --> TRAY[Linux tray / Windows read path]

    SW -.->|no ping| X[Forbidden]
    APP -.->|no ping| X
```

---

## 10. Optional modules (outside core engine)

```mermaid
flowchart TB
    WG[WAN Guard timer] -->|hub dual-WAN| DDNS[Update hub DDNS record]
    OVR[openvpn-recover.sh] -->|UniFi only| OVPN[Restart OpenVPN if down]

    CORE[tunnel-monitor-core] -.->|does not invoke| WG
    CORE -.->|does not invoke| OVR
```

See [`adapters/unifi-gateway/modules/wan-guard/README.md`](../../../adapters/unifi-gateway/modules/wan-guard/README.md).

---

## Related pages

- [VPN platform compatibility](vpn-platform-compatibility.md)
- [Setup guides](setup/README.md)
- [Information gaps](INFORMATION-GAPS.md)
