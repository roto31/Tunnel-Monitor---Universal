# GUI operator features (v2.0.1+)

Tunnel Monitor.app **reads** `/opt/tunnel-monitor/state.json` only. New in v2.0.1:

| Feature | Source | Operator action |
|---------|--------|-----------------|
| **Technical detail** | `DiagnosisReference.swift` | Popover → *Technical detail* disclosure |
| **Suggested steps** | Same runbook as CLI `--explain` | Listed under technical detail |
| **Stale state banner** | `MonitorState.isStale` (>12 min) | Orange banner in popover |
| **Schema version** | `state.json` `schema_version` | Header shows `Schema v2` |
| **Explain** | Opens Terminal | `tunnel-check --explain` |
| **Preflight** | Opens Terminal | `tunnel-check --preflight` |

Runbooks align with `vendor/core/lib/operator-explain.sh` and core diagnosis enum
(`GATEWAY_UNREACHABLE`, not legacy `UDR7_*` emit paths).

---

## GUI data flow

```mermaid
flowchart LR
    LD[launchd] --> ENG[monitor-engine.sh]
    ENG --> SJ[(state.json v2)]
    SJ --> MS[MonitorState poll]
    MS --> SP[StatusPresentation]
    SP --> DR[DiagnosisReference.guide]
    SP --> UI[Menu bar popover]

    UI -->|Explain| TC1[tunnel-check --explain]
    UI -->|Preflight| TC2[tunnel-check --preflight]
    TC1 --> OE[operator-explain.sh]
    TC2 --> OE
```

---

## Stale detection

```mermaid
flowchart TD
    READ[App reads state.json] --> PARSE[Parse timestamp ISO8601]
    PARSE --> AGE{now minus timestamp greater than 720s?}
    AGE -- yes --> STALE[Show stale banner]
    AGE -- no --> OK[No banner]
    STALE --> HINT[Force Check or verify launchd]
```

Default threshold: **720 seconds** (2× 5-minute check interval).

---

## Popover layout (v2.0.1)

```mermaid
flowchart TB
    subgraph Popover
        H[Header traffic light plus schema v2]
        I[Issues list]
        ST[Stale banner optional]
        TD[Technical detail disclosure]
        CH[Checks grid]
        DD[Gateway dedup block]
        ACT[Actions including Explain and Preflight]
    end
```

---

## Related

- [tunnel-monitor usage](../tunnel-monitor/04-usage-guide.md)
- [Signal flow](signal-flow-and-architecture.md)
- [RELEASES.md](../../RELEASES.md)
