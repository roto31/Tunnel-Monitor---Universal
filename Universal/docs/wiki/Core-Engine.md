# Core Engine

**Location:** `vendor/core/` (daily dev) and `tunnel-monitor-core/` (publish tree)

**Entry point:** `bin/monitor-engine.sh`

```bash
monitor-engine.sh --role gateway|lan_client --install-root PATH [--adapter-dir PATH] [check|diagnose|...]
```

## Diagnosis enum (first match wins)

```
OUR_INTERNET_DOWN → HEALTHY → GATEWAY_UNREACHABLE → DISAGREEMENT →
DDNS_DRIFT → REMOTE_INTERNET_DOWN → TUNNEL_DOWN
```

Legacy codes `UDR7_UNREACHABLE` and `ROUTER_UNREACHABLE` are still accepted in UI readers; core 2.x emits `GATEWAY_UNREACHABLE`.

## Gateway state line

- Regex: `^[0-9]+:(UP|DOWN)$`
- Examples: `0:UP`, `3:DOWN`

## LAN client state.json (v2)

- `schema_version`: 2
- Canonical dedup key: `gateway_dedup`
- Legacy keys dual-written: `udr7_dedup`, `router_dedup` (transition)

## Config aliases (core 2.x)

| Canonical | Legacy aliases |
|-----------|----------------|
| `GATEWAY_HOST` | `ROUTER_HOST`, `UDR7_HOST` |
| `GATEWAY_USER` | `ROUTER_USER`, `UDR7_USER` |
| `GATEWAY_KEY` | `ROUTER_KEY`, `UDR7_KEY` |
| `GATEWAY_STATE_PATH` | `ROUTER_STATE_PATH`, `UDR7_STATE_PATH` |

## Adapter hooks

| Hook | Purpose |
|------|---------|
| `hooks/diagnostics.sh` | Extra text appended to alert emails |
| `hooks/post_alert.sh` | Optional side effects after threshold crossed |
| `hooks/notify.sh` | Platform notifications (macOS osascript; Linux stub) |

## Tests

```bash
bats vendor/core/tests/
bash scripts/vendor-core.sh verify
```

Full contract: [CONTRACT.md](https://github.com/roto1231/Tunnel-Monitor---Universal/blob/main/vendor/core/CONTRACT.md)
