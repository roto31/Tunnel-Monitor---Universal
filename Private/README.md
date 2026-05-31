# Tunnel Monitor — Private (Mac Studio edition)

Operator-specific Mac Studio production edition. May contain real network identifiers.

## Layout

| Path | Purpose |
|------|---------|
| `app/` | Canonical Swift menu-bar GUI source |
| `install/` | Mac Studio install scripts (`install.sh`, `verify.sh`, `uninstall.sh`) |
| `payload/` | LaunchDaemon + SwiftBar payload for `/opt/tunnel-monitor/` |
| `SwiftBar/` | Legacy SwiftBar plugin source |
| `build/` | Ephemeral build staging (outputs in `build/dist/`) |
| `builds/releases/` | Immutable shipped GUI artifacts (`NN-vX.Y.Z/`) |
| `docs/` | Operator docs, private wiki, repo mirror, cursor prompts (gitignored) |
| `datasets/bundle-manifest.json` | Private release index + `dataRevision` |

## Build

```bash
cd Private
VERSION=2.0.0 bash build/build-app.sh
VERSION=2.0.0 bash build/build-pkg.sh
```

## Sync to Public

Public copies are sanitized via `Public/mac/sync-app-from-private.sh` — never edit Public GUI source directly.
