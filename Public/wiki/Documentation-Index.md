# Public documentation index

Guides for UniFi users replicating **two-sided VPN health monitoring**, **OpenVPN site-to-site** (when IPsec is blocked), and **WAN Guard** (dual-WAN DDNS protection).

All examples use **placeholders**. Configure real values via [[Placeholders-Reference]].

---

## Start here

| Audience | Read first |
|----------|------------|
| New to the project | [[Getting-Started]] |
| Ready to deploy | [[Implementation-Guide]] |
| Tunnel already up, need monitors | [[Architecture]] |
| Something broke | [[Troubleshooting]] |

---

## Guides by topic

### Core monitoring

| Document | Description |
|----------|-------------|
| [[Architecture]] | Components, dedup, state machine, diagrams |
| [[Spoke-Monitoring]] | Optional remote gateway + LAN monitors |
| [[Spoke-Templates]] | Spoke config templates + deploy scripts |
| [[macOS-Monitor]] | Mac / LAN-client install + CLI |
| [[Tunnel-Monitor-App]] | **Tunnel Monitor.app** hub (GUI docs + screenshots) |
| [[Tunnel-Monitor-App-Overview]] | GUI overview |
| [[Tunnel-Monitor-App-Architecture]] | GUI architecture (Mermaid) |
| [[Tunnel-Monitor-App-Setup]] | Install `.pkg` / wizard |
| [[Tunnel-Monitor-App-Menu-Bar]] | Menu bar popover & actions |
| [[Tunnel-Monitor-App-Troubleshooting]] | App troubleshooting |
| [[UniFi-Gateway-Monitor]] | UniFi gateway install + CLI |

### VPN transport

| Document | Description |
|----------|-------------|
| [[OpenVPN-Site-to-Site-Migration]] | OpenVPN when upstream modem blocks IPsec |
| [[WAN-Guard-OpenVPN-Failover]] | Dual-WAN + DDNS + OpenVPN stability |
| [[WAN-Guard-Install]] | WAN Guard quick install |

### Reference

| Document | Description |
|----------|-------------|
| [[Network-Overview]] | Generic topology (placeholder IPs) |
| [[Implementation-Guide]] | End-to-end replication checklist |
| [[Troubleshooting]] | Beginner steps + advanced diagnosis |
| [[Troubleshooting-Decision-Trees]] | If/then decision tables |
| [[Troubleshooting-Decision-Tree-Diagrams]] | Mermaid flowcharts |
| [[Workflow-Diagrams]] | Incident and install workflow diagrams |
| [[Placeholders-Reference]] | Every config placeholder |

---

## Terminology (public)

| Term | Meaning |
|------|---------|
| **Local hub** | Your home/office UniFi gateway (runs optional WAN Guard) |
| **Remote spoke** | The other site's UniFi gateway |
| **LAN client monitor** | Mac (or Linux/Windows port) on the local LAN |
| **Gateway monitor** | Bash + systemd on the UniFi gateway |
| **Dedup** | Mac suppresses email when gateway already alerted |

---

## External references

- [Ubiquiti — OpenVPN Site-to-Site](https://help.ui.com/hc/en-us/articles/12646699585047-UniFi-Gateway-OpenVPN-Site-to-Site)
- [Ubiquiti — Site-to-Site VPN overview](https://help.ui.com/hc/en-us/articles/115001218267-UniFi-Gateway-Route-Based-VPN-IPsec)
- [No-IP update API](https://www.noip.com/integrate/response)
- [RFC 5737 — documentation IPv4 blocks](https://www.rfc-editor.org/rfc/rfc5737)

---

## License

MIT — see [LICENSE](https://github.com/roto31/UniFi-Tunnel-Monitor/blob/main/LICENSE). No warranty; read scripts before production use.
