# Releases

Download macOS builds from the GitHub **Releases** tab:

**https://github.com/roto31/Tunnel-Monitor---Universal/releases**

## Current release: v2.0.0

| Artifact | Description |
|----------|-------------|
| `Tunnel-Monitor-2.0.0.pkg` | **Recommended** — GUI installer: app + launchd payload + SwiftBar plugin |
| `Tunnel-Monitor-2.0.0-macOS.app.zip` | Menu bar app only (no daemon install) |
| `CHECKSUMS.sha256` | SHA-256 checksums for verification |

### Install (pkg)

1. Download `Tunnel-Monitor-2.0.0.pkg`.
2. Open the pkg and enter an administrator password.
3. Edit `/opt/tunnel-monitor/config.env` — replace every `REPLACE_WITH_*` placeholder.
4. Open **Tunnel Monitor** from Applications (menu bar).
5. Verify: `tunnel-check diagnose` and `tunnel-check --test-email`.

### Verify checksum

```bash
shasum -a 256 -c CHECKSUMS.sha256
```

### What is included

- **Tunnel Monitor.app** — SwiftUI menu bar GUI (reads `state.json`, setup wizard)
- **LaunchDaemon** — `monitor-engine.sh --role lan_client` every 5 minutes
- **tunnel-monitor-core v2** — vendored under `/opt/tunnel-monitor/core/`
- **SwiftBar plugin** — optional menu bar script (deployed by postinstall)

### Not in this release

- UniFi gateway adapter (copy from `Universal/adapters/unifi-gateway/` manually)
- Generic Linux gateway (see wiki)
- Windows LAN client (see `Public/windows/`)
- Notarized/signed build unless release notes say otherwise

## Version matrix

| Tag | Core | Notes |
|-----|------|-------|
| [v2.0.0](https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.0) | 2.0.0 | Universal v2, `gateway_dedup` schema |
| v1.1.0 | — | Liquid Glass UI (pre-universal tree) |
| v1.0.0 | — | Initial public macOS release |

Full history: [`CHANGELOG.md`](CHANGELOG.md).

## Building from source

See [`RELEASING.md`](RELEASING.md).
