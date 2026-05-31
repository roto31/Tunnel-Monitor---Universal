# VPN setup guides

## Audience

| Role | Read |
|------|------|
| Operator | [UniFi Gateway](UniFi-Gateway), [Mac/Linux LAN Client](Mac-LAN-Client) |
| Admin | [Configuration](Configuration) + `config.env.template` |
| Architect | [Signal Flow](Signal-Flow-and-Architecture), [Compatibility](VPN-Platform-Compatibility) |
| Developer | [Core Engine](Core-Engine), `vendor/core/CONTRACT.md` |

## First-class (implemented)

| Platform | Wiki | Repo doc |
|----------|------|----------|
| UniFi gateway | [UniFi Gateway](UniFi-Gateway) | `adapters/unifi-gateway/` |
| Generic Linux gateway | [Generic Linux Gateway](Generic-Linux-Gateway) | `adapters/generic-linux-gateway/` |
| macOS LAN | [Mac LAN Client](Mac-LAN-Client) | `Public/mac/` |
| Linux LAN | [Linux LAN Client](Linux-LAN-Client) | `Public/linux/` |
| Windows LAN | — | `Public/windows/Install.ps1` |

Detailed steps: [implemented-adapters.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/setup/implemented-adapters.md)

## Category guides (no vendor adapter)

- [Enterprise VPN setup](Enterprise-VPN-Setup) — Cisco, Fortinet, Palo Alto
- [Cloud VPN setup](Cloud-VPN-Setup) — AWS, Azure, GCP
- [Open-source VPN setup](Open-Source-VPN-Setup) — OpenVPN, WireGuard, strongSwan

## Dual vantage (recommended)

Run **gateway monitor** on router/Linux sidecar **and** **LAN client** on Mac/Linux. Dedup suppresses duplicate emails when both see the same outage.

## Post-install verify

```bash
/opt/tunnel-monitor/tunnel-check diagnose
/opt/tunnel-monitor/tunnel-check ssh-test
/opt/tunnel-monitor/tunnel-check email-test
```

See [Troubleshooting](Troubleshooting).
