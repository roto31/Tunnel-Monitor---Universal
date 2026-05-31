# Contributing to Universal VPN Monitor (uvpn)

## Scope

uvpn monitors **point-to-point VPN** health on Linux and macOS. Do not expand into generic network monitoring, web dashboards, or telemetry platforms.

## Development setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
pytest -q
```

Optional Linux GUI:

```bash
pip install -e ".[dev,linux-gui]"
```

## Adding a VPN adapter

1. Subclass `uvpn.adapters.base.VpnAdapter` in `uvpn/adapters/`.
2. Register in `uvpn/adapters/registry.py`.
3. Add cited documentation in `docs/research/vpn-platforms.md`.
4. Add setup guide in `docs/vpn-solutions/<name>.md`.
5. Add tests if diagnosis logic is adapter-specific.

Adapters must return `AdapterStatus` without raising — the engine always completes a check cycle.

## Code style

- Python 3.11+ type hints on public APIs.
- Bash scripts: `#!/bin/bash`, `set -euo pipefail`, quoted expansions.
- Match existing module layout; minimal diffs.

## Pull requests

- Run `pytest` before opening a PR.
- Update `CHANGELOG.md` under `[Unreleased]` or the target version.
- Distinguish **Code**, **Data**, and **Build/CI** in changelog entries.

## Legacy stack

Changes under `legacy/` are for maintenance only. New features belong in uvpn unless explicitly requested.
