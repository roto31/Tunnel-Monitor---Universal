# Architecture

Tunnel Monitor uses **two vantage points** on the local site:

1. **Gateway monitor** — runs on the router; sees tunnel from the gateway perspective.
2. **LAN client monitor** (optional) — runs on a Mac or Linux box on the LAN; catches client routing issues the gateway might miss.

Both share the same **core engine** (`monitor-engine.sh`) with different **roles** and **adapters**.

## v2 stack

```
monitor-engine.sh
├── vendor/core/lib/     checks, diagnosis, state machine, dedup
├── adapter hooks/       platform diagnostics (ipsec, etc.)
└── install root         /opt/tunnel-monitor (LAN) or /data/tunnel-monitor (UniFi)
```

## State contracts

| Role | State file | Format |
|------|------------|--------|
| Gateway | `/data/tunnel-monitor/state` or adapter path | `N:UP` / `N:DOWN` |
| LAN client | `/opt/tunnel-monitor/state.json` | JSON v2 (see [Core Engine](Core-Engine)) |

The LAN client SSH-reads the gateway state line for **email dedup**.

## Dedup rules (LAN client)

| LAN sees | Gateway SSH | Gateway state | Email |
|----------|-------------|---------------|-------|
| Healthy | any | any | none |
| Down | unreachable | — | **alert** (`GATEWAY_UNREACHABLE`) |
| Down | reachable | `0:UP` | **alert** (`DISAGREEMENT`) |
| Down | reachable | `N:DOWN` | **suppress email** (banner still fires) |
| Down | reachable | `N:UP` (N>0) | alert (both converging) |

## Schedulers

| Platform | Scheduler | Interval |
|----------|-----------|----------|
| macOS | launchd | 5 min |
| Linux | systemd timer | 5 min |
| UniFi gateway | systemd timer | 5 min |

UI layers (SwiftBar, Tunnel Monitor.app, tray app) **read** `state.json` only — they never ping.

## Optional modules

- **WAN Guard** — hub dual-WAN DDNS protection ([WAN Guard](WAN-Guard))
- **OpenVPN recover** — UniFi only, off by default
- **Spoke templates** — `Public/spoke/` for remote-site monitors

See [Signal Flow and Architecture](Signal-Flow-and-Architecture) (v2 Mermaid) and the [repo architecture doc](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/architecture.md).
