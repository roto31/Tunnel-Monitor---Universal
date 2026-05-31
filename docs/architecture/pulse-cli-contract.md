# Pulse / Ivanti CLI contract (v1.0.0)

## Exit criteria (no lab)

Production-ready Pulse adapter requires:

1. **Documented connect syntax** — launcher switches for URL, user, password, realm (ISAC administration CLI chapter, 22.x)
2. **Monitoring subcommand** — `pulselauncher status` with stable stdout keys (`Connection Status`, `Server`, `Session ID`)
3. **Fixture variants** — all must parse correctly:
   - `connected.txt`
   - `disconnected.txt`
   - `error.txt`

Fixtures: `tests/fixtures/adapters/pulse/`

## Incorporated source material (maintainer record)

| Record id | Title | Version pin |
|-----------|-------|-------------|
| isac-cli-launcher | ISAC Administration — Command-line Launcher | 22.x |
| isac-linux-cli | ISAC Linux Quick Start — Command Line | vNow train |
| isac-install | ISAC Administration — Installation Overview | 22.x |

Retired public portal `docs.pulsesecure.net` must not be referenced in operator docs.

## Generic fallback

`vpn_type: generic` remains valid for **reachability-only** monitoring but does **not** satisfy Pulse adapter production status when ISAC is installed.

## Parser

- Implementation: `src/uvpn/adapters/cli_parse.py` — `parse_pulse_status()`
- Tests: `tests/test_adapters_enterprise.py`
