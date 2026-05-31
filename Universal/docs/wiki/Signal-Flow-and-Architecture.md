# Signal flow and architecture

Production Mermaid diagrams for v2 core **2.0.0**. Full text:
[repo doc](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/signal-flow-and-architecture.md).

## System context

```mermaid
flowchart TB
    subgraph Remote["Remote site"]
        RLAN["REMOTE_LAN_IP"]
        RWAN["REMOTE_WAN_IP"]
        RDDNS["REMOTE_DDNS"]
    end

    subgraph Local["Local site"]
        GWE["monitor-engine.sh gateway"]
        LCE["monitor-engine.sh lan_client"]
        GWState["state N:UP/DOWN"]
        JSON["state.json v2"]
        VPN["Site-to-site VPN"]
    end

    Internet((1.1.1.1))

    GWE -->|ping| RLAN
    LCE -->|ping| RLAN
    LCE -->|ping| RWAN
    LCE -->|dig| RDDNS
    LCE -->|ping| Internet
    GWE --> GWState
    LCE -->|SSH| GWState
    LCE --> JSON
```

The engine does **not** call vendor VPN APIs — ICMP + DNS + optional SSH only.

## LAN client check cycle

```mermaid
sequenceDiagram
    participant SCH as launchd or systemd
    participant ENG as monitor-engine.sh
    participant NET as Network
    participant SSH as ssh-gateway-state
    participant GW as Gateway state
    participant SMTP as send-email.sh
    participant FS as state.json

    SCH->>ENG: check
    ENG->>NET: ping REMOTE_LAN_IP
    ENG->>NET: ping REMOTE_WAN_IP
    ENG->>NET: ping 1.1.1.1
    ENG->>NET: dig REMOTE_DDNS
    ENG->>SSH: gateway dedup
    SSH->>GW: cat state file
    GW-->>SSH: state line UP or DOWN
    SSH-->>ENG: reachable and state
    ENG->>ENG: tm_compute_diagnosis
    alt threshold crossed
        ENG->>SMTP: alert or suppress dedup
    end
    ENG->>FS: atomic write
    ENG-->>SCH: exit 0
```

## Diagnosis tree (LAN client)

First match wins — see [Diagnoses and Alerts](Diagnoses-and-Alerts).

```mermaid
flowchart TD
    START([Checks done]) --> Q1{our internet up?}
    Q1 -- no --> OID[OUR_INTERNET_DOWN]
    Q1 -- yes --> Q2{tunnel ok?}
    Q2 -- yes --> H[HEALTHY]
    Q2 -- no --> Q3{gateway SSH ok?}
    Q3 -- no --> GU[GATEWAY_UNREACHABLE]
    Q3 -- yes --> Q4{state 0:UP?}
    Q4 -- yes --> DA[DISAGREEMENT]
    Q4 -- no --> Q5{DDNS match?}
    Q5 -- no --> DD[DDNS_DRIFT]
    Q5 -- yes --> Q6{remote WAN ok?}
    Q6 -- no --> RID[REMOTE_INTERNET_DOWN]
    Q6 -- yes --> TD[TUNNEL_DOWN]
```

## Email dedup

Suppress SMTP when gateway reachable, gateway state DOWN, and diagnosis is not `GATEWAY_UNREACHABLE` or `DISAGREEMENT`. Banner still fires.

## UI path

SwiftBar / Tunnel Monitor.app **read** `state.json` only — never ping.

## Optional modules (outside core)

- **WAN Guard** — hub dual-WAN DDNS ([WAN Guard](WAN-Guard))
- **OpenVPN recover** — UniFi only

See [Architecture](Architecture) for stack overview.
