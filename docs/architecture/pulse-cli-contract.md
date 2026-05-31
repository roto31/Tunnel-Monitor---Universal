# Pulse / Ivanti CLI contract (v1.0.0)

## Exit criteria (no lab)

Production-ready Pulse adapter requires:

1. **Documented command** — `pulselauncher status` or vendor wrapper `PulseClient.sh status`
2. **Pinned reference** — Ivanti Secure Access Client admin documentation (product portal)
3. **Fixture variants** — all must parse correctly:
   - `connected.txt`
   - `disconnected.txt`
   - `error.txt`

Fixtures live in [`tests/fixtures/adapters/pulse/`](../../tests/fixtures/adapters/pulse/).

## Source

- https://docs.pulsesecure.net/ (product-specific admin guides)

## Generic fallback

`vpn_type: generic` remains valid for **reachability-only** monitoring but does **not** satisfy Pulse adapter production status.

## Parser

Implementation: [`src/uvpn/adapters/cli_parse.py`](../../src/uvpn/adapters/cli_parse.py) — `parse_pulse_status()`.

Tests: [`tests/test_adapters_enterprise.py`](../../tests/test_adapters_enterprise.py).
