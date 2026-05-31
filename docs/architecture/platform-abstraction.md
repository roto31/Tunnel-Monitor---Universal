# Platform abstraction layer

The **MonitorAPI** (`src/uvpn/api/platform.py`) is the contract between the Python monitoring core and every frontend.

## Design goals

1. **Identical capabilities** — CLI, universal terminal, Linux GUI, and macOS GUI call the same methods.
2. **Stable JSON** — All methods return JSON-serializable structures for Swift/GTK/tkinter binding.
3. **No probe logic in GUIs** — Frontends never import adapters directly.

## API surface

| Method | Purpose | Used by |
|--------|---------|---------|
| `run_check()` | Full monitoring cycle | CLI `check`, TUI option 1, GUI refresh |
| `get_status()` | Last connection snapshot | CLI `status`, Status tab |
| `get_statistics()` | Probe + adapter metrics | CLI `statistics`, Statistics tab |
| `get_logs(limit)` | Recent log lines | CLI `logs`, Logs tab |
| `get_diagnostics()` | Diagnosis + runbook | CLI `diagnostics`, Diagnostics tab |
| `explain()` | Human runbook text | CLI `explain`, TUI option 5 |
| `preflight()` | Dependency validation | CLI `preflight`, TUI option 6 |
| `list_adapters()` | Registered VPN types | CLI `adapters` |
| `full_view()` | Combined `MonitorView` | Linux/macOS GUIs |

## MonitorView schema

```json
{
  "status": { "present": true, "diagnosis": "HEALTHY", "..." },
  "statistics": { "available": true, "probes": {}, "adapter": {} },
  "logs": ["line1", "line2"],
  "diagnostics": { "diagnosis": "HEALTHY", "steps": [] }
}
```

## Integration patterns

### Shell CLI / terminal

```bash
uvpn check
uvpn statistics
uvpn diagnostics
```

### Python GUI (Linux)

```python
from uvpn.api.platform import MonitorAPI
api = MonitorAPI()
view = api.full_view()
```

### Swift GUI (macOS)

Reads `~/.config/uvpn/state.json` written by `run_check()` — same fields as `MonitorView.status` plus `statistics` and `logs` top-level keys.

## Versioning

API schema version is tied to `CheckSnapshot.schema_version` (currently `1`). Bump when breaking JSON fields.
