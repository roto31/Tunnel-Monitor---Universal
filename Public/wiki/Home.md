Welcome to the **UniFi Tunnel Monitor** wiki.

Two-sided **site-to-site VPN health monitoring** for UniFi networks: a **gateway monitor** (systemd on your local hub) plus a **Mac LAN client monitor** (launchd, SwiftBar, email dedup). Optional **WAN Guard** protects hub DDNS on dual-WAN setups. **OpenVPN migration** guidance when upstream modems block IPsec.

Source: [github.com/roto31/UniFi-Tunnel-Monitor](https://github.com/roto31/UniFi-Tunnel-Monitor)

---

## Start here

| Page | Description |
|------|-------------|
| [[Documentation-Index]] | Full doc map and external references |
| [[Getting-Started]] | Overview, local hub vs remote spoke, prerequisites |
| [[Implementation-Guide]] | End-to-end replication checklist |
| [[Troubleshooting]] | Beginner steps + advanced diagnosis (if/then runbooks) |
| [[Troubleshooting-Decision-Trees]] | **If → then** tables for every diagnosis |
| [[Troubleshooting-Decision-Tree-Diagrams]] | Mermaid flowchart for each decision tree branch |
| [[Workflow-Diagrams]] | Mermaid: architecture, dual-WAN timeline, install order |
| [[Spoke-Monitoring]] | Optional remote-site monitors (inverted topology) |
| [[Spoke-Templates]] | Spoke deploy scripts + config templates |

---

## Architecture & diagrams

| Page | Description |
|------|-------------|
| [[Repository-Overview]] | Project goals, repo layout, quick diagram |
| [[Architecture]] | Components, data flow, dedup tree, state machine (Mermaid) |
| [[Network-Overview]] | Generic topology, dual WAN, monitoring flows (Mermaid) |
| [[Workflow-Diagrams]] | Incident + install workflow diagrams (Mermaid) |
| [[Placeholders-Reference]] | Every `REPLACE_WITH_*` config placeholder |

---

## VPN transport

| Page | Description |
|------|-------------|
| [[OpenVPN-Site-to-Site-Migration]] | When IPsec UDP 500/4500 is blocked (e.g. ISP modem) |
| [[WAN-Guard-OpenVPN-Failover]] | Dual-WAN DDNS protection + operator runbook (Mermaid) |
| [[WAN-Guard-Install]] | Quick install on UniFi gateway |

Monitors work over **IPsec or OpenVPN** — they ping `REMOTE_LAN_IP`; transport is independent.

---

## Tunnel Monitor.app (GUI)

Full guide with screenshots and Mermaid diagrams: **[[Tunnel-Monitor-App]]** hub.

| Page | Description |
|------|-------------|
| [[Tunnel-Monitor-App-Overview]] | What the app does / does not do |
| [[Tunnel-Monitor-App-Architecture]] | Data flow, alerts, config save (diagrams) |
| [[Tunnel-Monitor-App-Setup]] | `.pkg` and `install.sh` |
| [[Tunnel-Monitor-App-Configuration-SMTP]] | SMTP section (+ screenshot) |
| [[Tunnel-Monitor-App-Configuration-Topology]] | Tunnel IPs / DDNS (+ screenshot) |
| [[Tunnel-Monitor-App-Configuration-Gateway-SSH]] | Dedup SSH (+ screenshot) |
| [[Tunnel-Monitor-App-Configuration-Tuning]] | Thresholds & banners (+ screenshot) |
| [[Tunnel-Monitor-App-Menu-Bar]] | Popover & actions (+ screenshot) |
| [[Tunnel-Monitor-App-Dashboard]] | Dashboard window |
| [[Tunnel-Monitor-App-Settings]] | UserDefaults preferences |
| [[Tunnel-Monitor-App-Troubleshooting]] | App-specific fixes |

---

## Deploy guides

| Page | Description |
|------|-------------|
| [[macOS-Monitor]] | Mac install, CLI, alert runbook, failure drills |
| [[Menu-Bar-App]] | Legacy short reference → see [[Tunnel-Monitor-App]] |
| [[UniFi-Gateway-Monitor]] | Gateway install, CLI, alert runbook |
| [[Spoke-Monitoring]] | Optional spoke gateway + remote LAN monitors |
| [[Spoke-Templates]] | Spoke `config.env` templates + deploy scripts |
| [[Build-and-Release]] | `.app` / `.pkg`, codesign, GitHub Actions |

---

## Quick links

- **Clone:** `git clone https://github.com/roto31/UniFi-Tunnel-Monitor.git`
- **Docs in repo:** [docs/](https://github.com/roto31/UniFi-Tunnel-Monitor/tree/main/docs)

Read [[Placeholders-Reference]] before editing any `config.env`.
