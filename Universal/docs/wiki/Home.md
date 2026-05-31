# Tunnel Monitor — Universal Wiki

Portable **site-to-site VPN health monitoring** with a shared bash engine (`tunnel-monitor-core` v2) and platform **adapters**.

## What it does

- Pings the remote LAN over the VPN every 5 minutes (gateway + optional LAN client).
- Distinguishes tunnel down vs remote internet down vs DDNS drift vs local internet outage.
- Sends SMTP alerts after a configurable failure threshold (~15 minutes default).
- **Dedupes** duplicate emails when gateway and LAN client both see the same outage.
- macOS: banner notifications, menu bar app, SwiftBar plugin.

## Repository layout

| Path | Role |
|------|------|
| [`vendor/core`](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/vendor/core) | Shared engine (diagnosis, state machine, dedup) |
| [`adapters/`](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/adapters) | UniFi gateway, generic Linux gateway, LAN client manifests |
| [`Public/mac`](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/Public/mac) | macOS LaunchDaemon + Tunnel Monitor.app |
| [`Public/linux`](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/Public/linux) | Linux systemd LAN client |
| [`Public/unifi`](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/Public/unifi) | UniFi gateway monitor (+ optional WAN Guard) |

## Quick links

- [Getting Started](Getting-Started)
- [Architecture](Architecture)
- [Signal flow (Mermaid)](Signal-Flow-and-Architecture)
- [VPN platform compatibility](VPN-Platform-Compatibility)
- [VPN setup guides](VPN-Setup-Guides)
- [Core Engine](Core-Engine)
- [Configuration](Configuration)
- [Diagnoses and Alerts](Diagnoses-and-Alerts)
- [Troubleshooting](Troubleshooting)

## Version

- **Core:** 2.0.0 (`vendor/core/VERSION`)
- **Consumer:** see [`bundle-manifest.json`](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/bundle-manifest.json)
