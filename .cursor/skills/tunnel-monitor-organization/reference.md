# Tunnel Monitor path reference

## Top-level layout

```
Tunnel-Monitor/
├── Private/          # Mac Studio production
├── Public/           # Sanitized distributable
├── Universal/        # Shared engine + adapters
├── .github/
├── .cursor/
├── README.md         # Navigation hub
├── CHANGELOG.md
├── RELEASING.md
├── RELEASES.md
└── bundle-manifest.json
```

## Legacy → canonical

| Legacy | Canonical |
|--------|-----------|
| `app/` | `Private/app/` |
| `internal/` | `Private/docs/` |
| `install.sh` | `Private/install/install.sh` |
| `verify.sh` | `Private/install/verify.sh` |
| `uninstall.sh` | `Private/install/uninstall.sh` |
| `SwiftBar/` | `Private/SwiftBar/` |
| `build/` (root) | `Private/build/` |
| `payload/` | `Private/payload/` |
| `vendor/core/` | `Universal/vendor/core/` |
| `adapters/` | `Universal/adapters/` |
| `scripts/` | `Universal/scripts/` |
| `docs/v2/` | `Universal/docs/v2/` |
| `tunnel-monitor-core/` | `Universal/tunnel-monitor-core/` |
| `README.universal.md` | `Universal/README.md` |
| root `datasets/` | `{Category}/datasets/` |
| `private-docs-wiki/` | `Private/docs/wiki/` |
| `private-docs-repo/` | `Private/docs/repo/` |
| `.wiki-uni-tunnel-monitor/` | `Public/wiki/` |
| `.wiki-publish/` | `Universal/docs/wiki/` |
| `tunnel-monitor-cursor-prompt/` | `Private/docs/cursor-prompt/` |
| `CURSOR_PROMPT.md` (root) | `Private/docs/cursor-prompt/CURSOR_PROMPT.md` |
| `Public/build/releases/` | `Public/builds/releases/` |

## Compat shims (deprecated; remove next MAJOR)

| Shim | Forwards to |
|------|-------------|
| `install.sh` | `Private/install/install.sh` |
| `verify.sh` | `Private/install/verify.sh` |
| `uninstall.sh` | `Private/install/uninstall.sh` |
| `app/` | symlink or note → `Private/app/` |

## Version sources

| File | Scope |
|------|-------|
| `Private/VERSION` | Private GUI artifact |
| `Public/VERSION` | Public GUI artifact |
| `Universal/VERSION` | Core engine (mirrors `Universal/vendor/core/VERSION`) |
| `bundle-manifest.json` (root) | Cross-category index |
| `{Category}/datasets/bundle-manifest.json` | Release folder index |

## Sync scripts

- `Public/mac/sync-app-from-private.sh` — `Private/app/` → `Public/mac/app/` (sanitized Resources preserved)
- `Universal/scripts/vendor-core.sh` — core vendoring and verify
