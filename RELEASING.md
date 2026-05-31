# Releasing uvpn

## Versioning

- **uvpn** uses SemVer in `pyproject.toml` (`project.version`).
- Tag format: `uvpn-vX.Y.Z` (e.g. `uvpn-v1.0.0`).
- **0.2.0** was a development pre-release; **1.0.0** is the first production gate (enterprise adapters + scheduling).
- Legacy bash macOS artifacts use `vX.Y.Z` — see [legacy/RELEASING.md](legacy/RELEASING.md).

## Pre-release checklist

1. `pytest -q` passes.
2. `swift build -c release` in `src/gui-macos/UniversalVPNMonitor/`.
3. Enterprise adapter fixture tests pass (`tests/test_adapters_enterprise.py`).
4. `CHANGELOG.md` updated (Code / Data / Build categories).
5. Adapter docs cite official vendor sources; version matrix current.

## GitHub release (uvpn)

```bash
git tag uvpn-v1.0.0
git push origin uvpn-v1.0.0
```

The `uvpn-release.yml` workflow runs tests and attaches the Swift release binary.

Optional manual artifacts:

- Source tarball (default from GitHub)
- `UniversalVPNMonitor` release binary from CI

## CI

- **uvpn CI:** `.github/workflows/uvpn-ci.yml` on changes to `src/`, `scripts/`, `tests/`, `pyproject.toml`.
- **uvpn release:** `.github/workflows/uvpn-release.yml` on `uvpn-v*` tags.
- **Legacy release:** `.github/workflows/legacy-release.yml` on `v*` tags (bash `.pkg`).

## Scheduling artifacts

Shipped under `src/deploy/`:

| Platform | Files |
|----------|-------|
| Linux | `linux/uvpn.service`, `linux/uvpn.timer`, `linux/install-systemd.sh` |
| macOS | `macos/com.universal.uvpn.check.plist.template`, `macos/install-launchagent.sh` |

Install docs: [docs/platform-linux/installation.md](docs/platform-linux/installation.md), [docs/platform-macos/installation.md](docs/platform-macos/installation.md).
