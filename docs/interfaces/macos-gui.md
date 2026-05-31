# macOS GUI (Swift)

Native menu bar application reading shared `~/.config/uvpn/state.json`.

## Build

```bash
cd apps/macos/UniversalVPNMonitor
swift build -c release
.build/release/UniversalVPNMonitor
```

Requires macOS 14+; Liquid Glass styling targets macOS 26 when available.

## Workflow

1. Install and configure uvpn CLI (`pip install -e .`, `uvpn init-config`).
2. Run periodic checks: `uvpn check` (manual, cron, or launchd).
3. Launch menu bar app — polls `state.json` and offers Refresh / Run check.

The Swift app **does not embed probe logic** — it reflects engine output only.

## launchd timer (optional)

See [../platforms/macos/install.md](../platforms/macos/install.md) for `LaunchAgent` example running `uvpn check` every 5 minutes.

## vs legacy Tunnel Monitor.app

The legacy bash menu bar app under `legacy/Public/mac/` reads `/opt/tunnel-monitor/state.json`. **Do not confuse** with UniversalVPNMonitor — different schema, different engine.
