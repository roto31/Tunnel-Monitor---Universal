# Tunnel Monitor — Universal (v2)

Portable site-to-site VPN health monitoring with a shared **tunnel-monitor-core** engine and platform **adapters**.

## Architecture

- **`vendor/core/`** — bash engine (diagnosis tree, state machine, dedup, `state.json` v2)
- **`adapters/`** — UniFi gateway, generic Linux gateway, macOS/Linux LAN clients
- **`Public/`** — sanitized deployable bundles (mac, linux, unifi, docs, tray-app)
- **`tunnel-monitor-core/`** — publish tree for standalone core releases
- **`scripts/`** — `install-core.sh`, `vendor-core.sh`

See [`vendor/core/CONTRACT.md`](vendor/core/CONTRACT.md) and [`docs/v2/CONVERGENCE.md`](docs/v2/CONVERGENCE.md).

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
cd adapters/unifi-gateway
# copy to router, then on gateway:
bash install.sh
```

**Generic Linux gateway**

```bash
cd adapters/generic-linux-gateway
sudo bash install.sh
```

## Releases (macOS GUI + pkg)

Download builds from **[GitHub Releases](https://github.com/roto31/Tunnel-Monitor---Universal/releases)**.

| Artifact | Use |
|----------|-----|
| `Tunnel-Monitor-<version>.pkg` | Full install (app + launchd + payload) |
| `Tunnel-Monitor-<version>-macOS.app.zip` | Menu bar app only |

See [`RELEASES.md`](RELEASES.md) and [`CHANGELOG.md`](CHANGELOG.md). Maintainer guide: [`RELEASING.md`](RELEASING.md).

GUI operator features (v2.0.1+): [`Public/docs/v2/gui-operator-features.md`](Public/docs/v2/gui-operator-features.md).

## Versioning

- Core: `vendor/core/VERSION` (pinned in [`bundle-manifest.json`](bundle-manifest.json) as `coreVersion`)
- Consumer artifact: `artifactVersion` in bundle manifest

## Tests

```bash
bats vendor/core/tests/
bash scripts/vendor-core.sh verify
```

## Documentation

Public operator docs: [`Public/docs/`](Public/docs/) and [`Public/README.md`](Public/README.md).
