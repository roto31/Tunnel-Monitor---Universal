# Signal flow and architecture (v2)

Sources: `vendor/core/bin/monitor-engine.sh`, `vendor/core/lib/diagnosis.sh`,
`Public/mac/app/TunnelMonitor/Sources/TunnelMonitor/DiagnosisReference.swift`.

---

## 1. System context

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

---

## 2. LAN client check cycle

```mermaid
sequenceDiagram
    participant SCH as launchd or systemd
    participant ENG as monitor-engine.sh
    participant NET as Network
    participant SSH as ssh-gateway-state
    participant GW as Gateway state
    participant FS as state.json

    SCH->>ENG: check
    ENG->>NET: ping REMOTE_LAN_IP
    ENG->>NET: ping REMOTE_WAN_IP
    ENG->>NET: ping 1.1.1.1
    ENG->>NET: dig REMOTE_DDNS
    ENG->>SSH: gateway dedup
    SSH->>GW: cat state file
    GW-->>ENG: state line UP or DOWN
    ENG->>ENG: tm_compute_diagnosis
    ENG->>FS: atomic write schema v2
    ENG-->>SCH: exit 0
```

---

## 3. GUI read path (v2.0.1)

```mermaid
sequenceDiagram
    participant APP as Tunnel Monitor.app
    participant FS as state.json
    participant DR as DiagnosisReference
    participant TC as tunnel-check

    loop every 5 to 30s
        APP->>FS: read JSON
        APP->>APP: isStale if timestamp older than 12m
        APP->>DR: guide for diagnosis code
        APP->>APP: StatusPresentation plus technical detail
    end
    APP->>TC: Explain opens --explain
    APP->>TC: Preflight opens --preflight
```

---

## 4. Diagnosis tree (LAN client)

First match wins — `tm_compute_diagnosis`.

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

GUI maps legacy `UDR7_UNREACHABLE` / `ROUTER_UNREACHABLE` when reading old state.

---

## 5. Email dedup

```mermaid
flowchart TD
    A[Threshold crossed] --> B{GATEWAY_UNREACHABLE or DISAGREEMENT?}
    B -- yes --> SEND[Send email]
    B -- no --> C{gateway reachable and DOWN?}
    C -- yes --> SUP[Suppress email]
    C -- no --> SEND
    SUP --> BAN[Banner still fires]
```

See also [gui-operator-features.md](gui-operator-features.md).
