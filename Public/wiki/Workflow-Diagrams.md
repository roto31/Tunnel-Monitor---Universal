# Workflow diagrams

Mermaid diagrams for monitoring, failover, and incident response. Uses **placeholder** addresses ([[Placeholders-Reference]]). Render on GitHub wiki, or paste into [mermaid.live](https://mermaid.live).

Related: [[Architecture]], [[Network-Overview]], [[Troubleshooting-Decision-Trees]], [[Troubleshooting]].

---

## 1. End-to-end monitoring architecture

```mermaid
flowchart TB
    subgraph MAC["Mac LAN client 192.0.2.10"]
        M["monitor.sh<br/>every 5 min"]
        SJ[("state.json")]
        SB["SwiftBar 30s"]
        TC["tunnel-check"]
        M --> SJ
        SJ --> SB
        SJ --> TC
    end

    subgraph HUB["Local hub 192.0.2.1"]
        UM["tunnel-monitor<br/>every 5 min"]
        US[("state N:UP")]
        WG["WAN Guard<br/>every 5 min"]
        WS[("wan-guard.state")]
        OVPN["Site-to-Site OpenVPN<br/>10.255.0.1"]
        UM --> US
        WG --> WS
    end

    subgraph SPOKE["Remote spoke 198.51.100.1"]
        RVPN["Spoke-to-Hub-OpenVPN<br/>10.255.0.2"]
        POL["Policy routing<br/>optional"]
        RVPN --> POL
    end

    NOIP["DDNS hub.example.com"]
    SMTP["SMTP provider<br/>587"]

    M -->|"ping REMOTE_LAN_IP"| SPOKE
    M -->|"SSH dedup"| US
    UM -->|"ping REMOTE_LAN_IP"| SPOKE
    WG -->|"read primary WAN"| NOIP
    SPOKE -->|"dial hub.example.com:1194"| OVPN
    M --> SMTP
    UM --> SMTP
    WG --> SMTP
```

---

## 2. Mac diagnosis flow (one cycle)

Same logic as [[Architecture]] §3 and `diagnose()` in `monitor.sh`.

```mermaid
flowchart TD
    START([monitor.sh tick]) --> P1{ping 1.1.1.1?}
    P1 -- no --> OID[OUR_INTERNET_DOWN<br/>no alert]
    P1 -- yes --> P2{ping REMOTE_LAN_IP?}
    P2 -- yes --> OK[HEALTHY<br/>recovery if was DOWN]
    P2 -- no --> P3{SSH ROUTER_HOST OK?}
    P3 -- no --> UU[ROUTER_UNREACHABLE]
    P3 -- yes --> P4{state == 0:UP?}
    P4 -- yes --> DIS[DISAGREEMENT]
    P4 -- no --> P5{dig REMOTE_DDNS<br/>== REMOTE_WAN_IP?}
    P5 -- no --> DD[DDNS_DRIFT]
    P5 -- yes --> P6{ping REMOTE_WAN_IP?}
    P6 -- no --> RID[REMOTE_INTERNET_DOWN]
    P6 -- yes --> TD[TUNNEL_DOWN]

    UU --> ALERT
    DIS --> ALERT
    DD --> ALERT
    RID --> ALERT
    TD --> DEDUP{gateway state<br/>N:DOWN?}
    DEDUP -- yes --> BAN[banner only]
    DEDUP -- no --> ALERT[banner + email]
```

**If/then reference:** [[Troubleshooting-Decision-Trees]].

---

## 3. Dual-WAN failover timeline

When local hub has **primary public WAN** + **backup CGNAT WAN** and remote VPN dials **hub DDNS**.

```mermaid
sequenceDiagram
    participant PRI as Primary WAN<br/>public IP
    participant HUB as Local hub
    participant WG as WAN Guard
    participant DNS as hub.example.com
    participant SPOKE as Remote spoke<br/>OpenVPN client

    Note over PRI,SPOKE: Normal — in_sync
    PRI->>HUB: primary link up
    WG->>PRI: read public IP
    WG->>DNS: sync if changed
    SPOKE->>DNS: resolve public IP
    SPOKE->>HUB: OpenVPN connected

    Note over PRI,SPOKE: Outage — primary down
    PRI--xHUB: link lost
    HUB->>HUB: failover to backup CGNAT
    WG->>WG: primary down/private<br/>BLOCK DDNS update
    WG->>WG: alert CGNAT blocked
    DNS->>DNS: keep last public record
    SPOKE->>DNS: still resolves public IP
    Note over SPOKE: May fail if route dead<br/>policy kill switch active

    Note over PRI,SPOKE: Recovery
    PRI->>HUB: primary restored
    WG->>DNS: update if IP changed
    SPOKE->>HUB: OpenVPN reconnect
```

Detail: [[WAN-Guard-OpenVPN-Failover]].

---

## 4. OpenVPN site-to-site path

Generic layout after migrating off blocked IPsec.

```mermaid
flowchart LR
    subgraph HUB["Local hub"]
        H_WAN["Primary WAN<br/>public IP"]
        H_OVPN["OpenVPN server<br/>10.255.0.1:1194"]
        H_LAN["192.0.2.0/24"]
        H_WAN --> H_OVPN
        H_OVPN --> H_LAN
    end

    subgraph I["Internet"]
        DNS["hub.example.com"]
    end

    subgraph SPOKE["Remote spoke"]
        MODEM["ISP modem<br/>REMOTE_WAN_IP"]
        S_OVPN["OpenVPN client<br/>10.255.0.2"]
        S_LAN["198.51.100.0/24"]
        MODEM --> S_OVPN
        S_OVPN --> S_LAN
    end

    S_OVPN -->|"UDP 1194"| DNS
    DNS --> H_WAN
    H_LAN <-. "routed subnets" .-> S_LAN
```

Setup: [[OpenVPN-Site-to-Site-Migration]].

---

## 5. IPsec failure investigation

Use when IPsec never establishes — common on modems that filter UDP 500/4500.

```mermaid
flowchart TD
    A[IPsec won't establish] --> B{UDP 500/4500<br/>reach UniFi WAN?}
    B -- no --> C[Upstream blocks IPsec<br/>migrate OpenVPN]
    B -- yes --> D{IKE versions<br/>match?}
    D -- no --> E[Align IKE on both UniFi]
    D -- yes --> F[Check keys IDs subnets]
    E --> G{Still down?}
    F --> G
    G -- yes on double-NAT --> C
```

---

## 6. Operator incident workflow

```mermaid
flowchart TD
    ALERT([Alert received]) --> READ[Read diagnosis<br/>in subject or banner]
    READ --> CHECK[tunnel-check<br/>Mac and gateway]
    CHECK --> TREE[Match decision tree page]
    TREE --> FIX[Apply fix]
    FIX --> VERIFY[Verify:<br/>ping REMOTE_LAN_IP<br/>tunnel-check HEALTHY<br/>wan-guard in_sync if used]
    VERIFY --> DONE([Close incident])
    VERIFY -- fail --> ESC[SSH local hub<br/>openvpn or ipsec logs<br/>wan-guard status]
    ESC --> TREE
```

---

## 7. Component install dependency order

Recommended greenfield order ([[Implementation-Guide]]):

```mermaid
flowchart TD
    A[Site-to-site VPN<br/>IPsec or OpenVPN] --> B[Gateway tunnel-monitor]
    B --> C[Mac LAN monitor<br/>plus SSH dedup key]
    C --> D{Dual WAN plus<br/>remote dials DDNS?}
    D -- yes --> E[WAN Guard on local hub]
    D -- no --> F[Acceptance tests]
    E --> G[Disable UniFi DDNS<br/>on both WANs]
    G --> F
    F --> H[Optional policy routing<br/>over VPN interface]
```

---

## 8. Gateway-side alert classification

Simpler tree than Mac side — no SSH dedup.

```mermaid
flowchart TD
    START([gateway monitor tick]) --> P1{ping REMOTE_LAN_IP?}
    P1 -- yes --> OK[HEALTHY]
    P1 -- no --> P2{ping REMOTE_WAN_IP?}
    P2 -- no --> RID[REMOTE INTERNET DOWN]
    P2 -- yes --> P3{dig REMOTE_DDNS<br/>== REMOTE_WAN_IP?}
    P3 -- no --> DD[DDNS DRIFT]
    P3 -- yes --> TD[TUNNEL DOWN]
```

After `FAILURE_THRESHOLD` failures, email subject matches diagnosis.
