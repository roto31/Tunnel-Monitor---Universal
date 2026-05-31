# VPN platform diagrams (uvpn)

Mermaid diagrams and visual assets for vendor guides under [../vpn-solutions/](../vpn-solutions/). Wiki mirror: regenerate with `python3 scripts/sync-wiki-vpn-guides.py` and edit this file for index pages.

**Visual assets (PNG + SVG):** [../vpn-solutions/assets/](../vpn-solutions/assets/README.md)

---

## System interfaces (v1.1)

```mermaid
flowchart TB
    subgraph ifaces [Interfaces]
        CLI[uvpn CLI]
        TUI[uvpn-tui]
        LGUI[Linux GTK]
        MGUI[macOS Swift]
        SD[uvpn-statusd optional]
    end
    subgraph core [Python core]
        API[MonitorAPI]
        ENG[MonitorEngine]
        ST[state.json]
        RED[PublicStatusDTO]
    end
    CLI --> API
    TUI --> API
    LGUI --> API
    API --> ENG
    ENG --> ST
    MGUI --> ST
    ST --> RED
    RED --> SD
```

Full design: [system-design.md](system-design.md) · Security: [../security/nist-portal-architecture.md](../security/nist-portal-architecture.md)

---

## Diagram types (every platform guide)

| Diagram | Purpose |
|---------|---------|
| Visual reference | Static PNG topology (repo `assets/`) |
| Product architecture | Vendor admin / user guide topology |
| Connection lifecycle | Vendor session states + exit codes where applicable |
| uvpn monitoring flow | Adapter CLI + probes + diagnosis + state.json + optional statusd |

---

## Platform index

| Platform | Guide | Visual |
|----------|-------|--------|
| OpenVPN | [openvpn.md](../vpn-solutions/openvpn.md) | `openvpn-architecture.png` |
| WireGuard | [wireguard.md](../vpn-solutions/wireguard.md) | `wireguard-architecture.png` |
| IPsec/IKEv2 | [ipsec-ikev2.md](../vpn-solutions/ipsec-ikev2.md) | `ipsec-architecture.png` |
| Cisco Secure Client | [cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md) | `cisco-architecture.png` |
| FortiClient | [fortinet-forticlient.md](../vpn-solutions/fortinet-forticlient.md) | `fortinet-architecture.png` |
| GlobalProtect | [palo-alto-globalprotect.md](../vpn-solutions/palo-alto-globalprotect.md) | `globalprotect-architecture.png` |
| Pulse/Ivanti | [pulse-ivanti.md](../vpn-solutions/pulse-ivanti.md) | `pulse-architecture.png` |

---

## Enterprise comparison

```mermaid
flowchart TB
    subgraph uvpn [uvpn MonitorEngine]
        E[Engine]
        P[Universal ICMP + DDNS probes]
    end
    subgraph adapters [Vendor CLI adapters v1.0]
        F[fortinet]
        G[globalprotect]
        PU[pulse]
        C[cisco_anyconnect]
    end
    subgraph consumers [Consumers]
        CLI[CLI TUI GUI]
        RED[PublicStatusDTO]
        SD[statusd optional]
    end
    E --> F
    E --> G
    E --> PU
    E --> C
    E --> P
    F --> D[Diagnosis + state.json]
    G --> D
    PU --> D
    C --> D
    P --> D
    D --> TD[TUNNEL_DOWN when CLI up + LAN fail]
    D --> ST[state.json]
    ST --> CLI
    ST --> RED
    RED --> SD
```

---

## Pulse — monitoring flow (example)

```mermaid
flowchart TB
    E[MonitorEngine] --> A[pulse adapter]
    A -->|pulselauncher status| CLI[Parse stdout fields]
    CLI -->|empty| EC[Supplement exit code]
    E --> P[ICMP + DDNS probes]
    CLI --> D[Diagnosis]
    EC --> D
    P --> D
    D -->|Connected + LAN fail| TD[VPN_NEGOTIATION_FAILED]
    D --> ST[state.json]
    ST --> RED[PublicStatusDTO strips raw and logs]
    RED --> SD[statusd optional HTTPS]
```

---

## GlobalProtect — dual CLI path

```mermaid
flowchart LR
    E[MonitorEngine] --> A[globalprotect adapter]
    A -->|default macOS| GPCTL[gpctl show status]
    A -->|Linux 6.x override| GPCMD[globalprotect show --status]
    GPCTL --> PARSER[Fixture parser]
    GPCMD --> PARSER
    E --> PR[ICMP probes]
    PARSER --> D[Diagnosis]
    PR --> D
    D --> ST[state.json]
    ST --> RED[PublicStatusDTO]
    RED --> SD[statusd optional]
```

---

## FortiClient — platform CLI selection

```mermaid
flowchart LR
    E[MonitorEngine] --> A[fortinet adapter]
    A -->|pick binary| L[Linux forticlient vpn status]
    A -->|pick binary| W[Windows FortiVPN --cli --status]
    L --> PARSE[Fixture parser 7.x]
    W --> PARSE
    E --> P[ICMP probes]
    PARSE --> D[Diagnosis]
    P --> D
    D --> ST[state.json]
    ST --> RED[PublicStatusDTO]
    RED --> SD[statusd optional]
```
