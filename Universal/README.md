# Tunnel Monitor — Universal (v2)

Portable site-to-site VPN health monitoring with a shared **tunnel-monitor-core** engine and platform **adapters**.

## Architecture

- **`Universal/vendor/core/`** — bash engine (diagnosis tree, state machine, dedup, `state.json` v2)
- **`Universal/adapters/`** — UniFi gateway, generic Linux gateway, macOS/Linux LAN clients
- **`Public/`** — sanitized deployable bundles (mac, linux, unifi, docs, tray-app)
- **`Private/`** — Mac Studio production edition (canonical GUI source, operator docs)
- **`Universal/tunnel-monitor-core/`** — publish tree for standalone core releases
- **`Universal/scripts/`** — `install-core.sh`, `vendor-core.sh`, `validate-folder-structure.sh`

See [`Universal/vendor/core/CONTRACT.md`](vendor/core/CONTRACT.md) and [`Universal/docs/v2/CONVERGENCE.md`](docs/v2/CONVERGENCE.md).

## Quick start

**Mac LAN client**

```bash
cd Public/mac
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env
tunnel-check --test-email
```

**UniFi gateway**

```bash
cd Universal/adapters/unifi-gateway
# copy to router, then on gateway:
bash install.sh
```

**Generic Linux gateway**

```bash
cd Universal/adapters/generic-linux-gateway
sudo bash install.sh
```

## Versioning

- Core: `Universal/vendor/core/VERSION` (pinned in [`bundle-manifest.json`](../bundle-manifest.json) as `coreVersion`)
- Public GUI: `Public/VERSION` + `Public/datasets/bundle-manifest.json`
- Private GUI: `Private/VERSION` + `Private/datasets/bundle-manifest.json`

## Releases (macOS GUI + pkg)

Download builds from **[GitHub Releases](https://github.com/roto31/Tunnel-Monitor---Universal/releases)**.

| Artifact | Use |
|----------|-----|
| `Tunnel-Monitor-<version>.pkg` | Full install (app + launchd + payload) |
| `Tunnel-Monitor-<version>-macOS.app.zip` | Menu bar app only |

See [`RELEASES.md`](../RELEASES.md) and [`CHANGELOG.md`](../CHANGELOG.md). Maintainer guide: [`RELEASING.md`](../RELEASING.md).

## Tests

```bash
bats Universal/vendor/core/tests/
bash Universal/scripts/vendor-core.sh verify
bash Universal/scripts/validate-folder-structure.sh
```

## Documentation

Public operator docs: [`Public/docs/`](../Public/docs/) and [`Public/README.md`](../Public/README.md).
