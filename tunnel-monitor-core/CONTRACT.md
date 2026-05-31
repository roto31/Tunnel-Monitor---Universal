# tunnel-monitor-core contract (v2)

## Gateway state line

- Format: `^[0-9]+:(UP|DOWN)$`
- Example: `3:DOWN`

## LAN client state.json

- `schema_version`: 2 when written by core ≥2.0
- Canonical dedup key: `gateway_dedup`
- Legacy keys dual-written: `udr7_dedup`, `router_dedup`

## Diagnosis enum (first match wins)

```
OUR_INTERNET_DOWN → HEALTHY → GATEWAY_UNREACHABLE → DISAGREEMENT →
DDNS_DRIFT → REMOTE_INTERNET_DOWN → TUNNEL_DOWN
```

Legacy codes `UDR7_UNREACHABLE` and `ROUTER_UNREACHABLE` are accepted in readers; not emitted by core 2.x.

## Email dedup suppress (LAN client)

Suppress email when gateway reachable, `GATEWAY_ALERT=DOWN`, and diagnosis is not `GATEWAY_UNREACHABLE` or `DISAGREEMENT`. Banner/notify still fires.

## Example state.json (healthy)

```json
{
  "schema_version": 2,
  "timestamp": "2026-05-30T12:00:00-05:00",
  "alert_state": "UP",
  "failure_count": 0,
  "diagnosis": "HEALTHY",
  "checks": {
    "tunnel": { "target": "192.168.0.1", "ok": true, "latency_ms": 12 },
    "remote_wan": { "target": "203.0.113.1", "ok": true, "latency_ms": 20 },
    "our_internet": { "target": "1.1.1.1", "ok": true, "latency_ms": 8 },
    "dns": { "host": "remote.example.com", "resolved": "203.0.113.1", "expected": "203.0.113.1", "match": true }
  },
  "gateway_dedup": { "reachable": true, "state": "0:UP", "checked_at": "2026-05-30T12:00:00-05:00" },
  "udr7_dedup": { "reachable": true, "state": "0:UP", "checked_at": "2026-05-30T12:00:00-05:00" },
  "router_dedup": { "reachable": true, "state": "0:UP", "checked_at": "2026-05-30T12:00:00-05:00" },
  "last_alert_sent_at": null,
  "last_recovery_sent_at": null,
  "down_since": null
}
```
