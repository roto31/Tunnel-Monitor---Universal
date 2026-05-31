# Tunnel Monitor App

Native **macOS menu bar** application (SwiftUI). Reads `/opt/tunnel-monitor/state.json` — does not run its own health checks.

**Source:** `Public/mac/app/TunnelMonitor/`

## Features

- Traffic-light menu bar status (green / yellow / red)
- Popover with live checks, gateway dedup, diagnosis
- Setup wizard for `config.env` (SMTP, topology, gateway SSH)
- Operator actions: kickstart daemon, test email, copy SSH auth command

## Build

```bash
cd Public/mac/app/TunnelMonitor
swift build -c release
# or use Public/build/build-app.sh from repo root
```

## state.json v2

App decodes dedup in priority order:

1. `gateway_dedup` (canonical)
2. `udr7_dedup` (legacy)
3. `router_dedup` (legacy)

Diagnosis display maps `GATEWAY_UNREACHABLE`, `UDR7_UNREACHABLE`, and `ROUTER_UNREACHABLE` to the same operator message.

## Docs

Full GUI guide: [Public/docs/tunnel-monitor/](https://github.com/roto1231/Tunnel-Monitor---Universal/tree/main/Public/docs/tunnel-monitor)
