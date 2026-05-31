# Tunnel Monitor.app — documentation hub

Native **macOS menu bar application** for the LAN-client VPN monitor: traffic-light status, **Configuration** window, operator actions, and optional dashboard — layered on `/opt/tunnel-monitor/` (LaunchDaemon + `monitor.sh`).

**Repo mirror:** [docs/tunnel-monitor](https://github.com/roto31/UniFi-Tunnel-Monitor/tree/main/docs/tunnel-monitor) · **Source:** [mac/app/TunnelMonitor](https://github.com/roto31/UniFi-Tunnel-Monitor/tree/main/mac/app/TunnelMonitor)

The app **does not run health checks**; it reads `state.json` written every five minutes by the daemon.

---

## GUI surfaces (subsections)

| Surface | Wiki page |
|---------|-----------|
| Overview & skill paths | [[Tunnel-Monitor-App-Overview]] |
| Architecture & Mermaid diagrams | [[Tunnel-Monitor-App-Architecture]] |
| Install (.pkg / install.sh) | [[Tunnel-Monitor-App-Setup]] |
| **Configuration window** | |
| → SMTP | [[Tunnel-Monitor-App-Configuration-SMTP]] |
| → Tunnel topology | [[Tunnel-Monitor-App-Configuration-Topology]] |
| → Gateway SSH (dedup) | [[Tunnel-Monitor-App-Configuration-Gateway-SSH]] |
| → Tuning & notifications | [[Tunnel-Monitor-App-Configuration-Tuning]] |
| Menu bar popover & actions | [[Tunnel-Monitor-App-Menu-Bar]] |
| Dashboard window | [[Tunnel-Monitor-App-Dashboard]] |
| Settings | [[Tunnel-Monitor-App-Settings]] |
| Troubleshooting (app + daemon) | [[Tunnel-Monitor-App-Troubleshooting]] |

---

## Audience routing

| You are… | Start here |
|----------|------------|
| New user | [[Tunnel-Monitor-App-Setup]] → [[Tunnel-Monitor-App-Configuration-SMTP]] → [[Tunnel-Monitor-App-Menu-Bar]] |
| Daily operator | [[Tunnel-Monitor-App-Menu-Bar]] |
| Integrator | [[Tunnel-Monitor-App-Architecture]] → [[Architecture]] → [[macOS-Monitor]] |

---

## Related wiki pages

| Topic | Page |
|-------|------|
| Bash daemon + CLI | [[macOS-Monitor]] |
| Full stack (gateway + Mac) | [[Architecture]] |
| OpenVPN transport | [[OpenVPN-Site-to-Site-Migration]] |
| Placeholders | [[Placeholders-Reference]] |
| Build `.app` / `.pkg` | [[Build-and-Release]] |
| Legacy short reference | [[Menu-Bar-App]] |

---

## Screenshots & diagrams

All setup screenshots and menu bar example images live in the [public repo `docs/tunnel-monitor/images/`](https://github.com/roto31/UniFi-Tunnel-Monitor/tree/main/docs/tunnel-monitor/images). Wiki pages embed them via raw GitHub URLs so they render on github.com/wiki.
