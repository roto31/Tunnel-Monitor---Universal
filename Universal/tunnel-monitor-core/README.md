# tunnel-monitor-core

Portable bash monitoring engine for site-to-site VPN health checks.

This directory is the **publish tree** for the `tunnel-monitor-core` GitHub repository.
Daily development happens in [`../vendor/core/`](../vendor/core/); sync with:

```bash
./scripts/vendor-core.sh sync-publish tunnel-monitor-core
```

## Version

See [`VERSION`](VERSION) (currently 2.0.0).

## Layout

- `lib/` — shared modules (checks, diagnosis, state machine, dedup)
- `bin/monitor-engine.sh` — entry point (`--role gateway|lan_client`)
- `tests/` — bats fixtures
- `CONTRACT.md` — state formats and diagnosis enum

## Consumer

[`UniFi-Tunnel-Monitor`](../) vendors this core and ships platform adapters under `adapters/`.
