# macOS GUI (Swift)

Native menu bar application reading shared `~/.config/uvpn/state.json`.

## Build

```bash
cd src/gui-macos/UniversalVPNMonitor
swift build -c release
.build/release/UniversalVPNMonitor
```

Requires macOS 14+; Liquid Glass styling on macOS 26+ with material fallback on older releases.

## Workflow

1. Install and configure uvpn CLI (`pip install -e .`, `uvpn init-config`).
2. Run periodic checks: `uvpn check` or install [LaunchAgent](../deploy/scheduling.md).
3. Launch menu bar app — polls `state.json` every 15s.

## Menu bar features (v1.0)

| Feature | Behavior |
|---------|----------|
| Status badge | Traffic-light color from `state.json` |
| Stale banner | Orange warning when timestamp > 12 minutes |
| Statistics / Logs / Diagnostics | Disclosure groups |
| Refresh / Run check | Reload state or invoke `uvpn check` |
| Explain / Preflight / Adapters | Shell out to `uvpn` CLI; results in sheet |

The Swift app **does not embed probe logic** — it reflects engine output only.

## Periodic checks

```bash
bash src/deploy/macos/install-launchagent.sh
```

See [scheduling.md](../deploy/scheduling.md).

## vs legacy Tunnel Monitor.app

The legacy bash menu bar app under `legacy/Public/mac/` reads `/opt/tunnel-monitor/state.json`. **Do not confuse** with UniversalVPNMonitor — different schema, different engine.
