# Pulse / Ivanti CLI contract (v1.0.0)

## Exit criteria (no lab)

Production-ready Pulse adapter requires:

1. **Documented command** — `pulselauncher status` or vendor wrapper `PulseClient.sh status`
2. **Pinned reference** — [Ivanti ISAC Administration Guide](https://help.ivanti.com/ps/help/en_US/ISAC/22.X/ag-22.X/cli_launcher.htm) (22.x) and [Linux CLI QSG](https://help.ivanti.com/ps/help/en_US/ISAC/vNow/linux-qsg/using-linux-client-command-line.htm)
3. **Fixture variants** — all must parse correctly:
   - `connected.txt`
   - `disconnected.txt`
   - `error.txt`

Fixtures live in [`tests/fixtures/adapters/pulse/`](../../tests/fixtures/adapters/pulse/).

## Source

- **Primary portal:** https://help.ivanti.com/ps/
- **CLI launcher:** https://help.ivanti.com/ps/help/en_US/ISAC/22.X/ag-22.X/cli_launcher.htm
- **Linux CLI:** https://help.ivanti.com/ps/help/en_US/ISAC/vNow/linux-qsg/using-linux-client-command-line.htm

> `https://docs.pulsesecure.net/` is **retired** — do not use in links or docs.

## Generic fallback

`vpn_type: generic` remains valid for **reachability-only** monitoring but does **not** satisfy Pulse adapter production status.

## Parser

Implementation: [`src/uvpn/adapters/cli_parse.py`](../../src/uvpn/adapters/cli_parse.py) — `parse_pulse_status()`.

Tests: [`tests/test_adapters_enterprise.py`](../../tests/test_adapters_enterprise.py).
