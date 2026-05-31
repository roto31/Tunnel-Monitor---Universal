# Releasing uvpn

## Versioning

- **uvpn** uses SemVer in `pyproject.toml` (`project.version`).
- Tag format: `uvpn-vX.Y.Z` (e.g. `uvpn-v0.1.0`).
- Legacy bash macOS artifacts use `vX.Y.Z` — see [legacy/RELEASING.md](legacy/RELEASING.md).

## Pre-release checklist

1. `pytest -q` passes.
2. `swift build -c release` in `apps/macos/UniversalVPNMonitor/`.
3. `CHANGELOG.md` updated.
4. Adapter docs cite official vendor sources.

## GitHub release (uvpn)

```bash
git tag uvpn-v0.1.0
git push origin uvpn-v0.1.0
```

Attach optional artifacts:

- Source tarball (default from GitHub)
- `UniversalVPNMonitor` release binary (future: signed `.app`)

## CI

- **uvpn CI:** `.github/workflows/uvpn-ci.yml` on changes to `uvpn/`, `apps/`, `tests/`, `docs/`.
- **Legacy release:** `.github/workflows/legacy-release.yml` on `v*` tags (bash `.pkg`).
