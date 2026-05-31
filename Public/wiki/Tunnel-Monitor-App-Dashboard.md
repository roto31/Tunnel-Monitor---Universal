# Dashboard window

[← Hub](Tunnel-Monitor-App)

Optional **resizable window** with the same status presentation as the menu bar popover, plus more room for checks and issues.

---

## Open

- **Open Dashboard** from [[Tunnel-Monitor-App-Menu-Bar]]
- Or enable **Show dashboard on launch** in [[Tunnel-Monitor-App-Settings]]

Window id: `dashboard` in SwiftUI `WindowGroup`.

---

## Contents

| Area | Source |
|------|--------|
| Traffic-light summary | `MonitorState` + `StatusPresentation` |
| Checks grid | `state.json` → `checks` |
| Issues list | Derived diagnosis / failure count |
| Last updated | Timestamp from JSON |

Polling interval follows **Settings** (5 / 15 / 30 s) — does not change daemon schedule (5 min).

---

## When to use

- Longer monitoring session on a large display
- Screenshots / screen sharing without opening the popover each time

Daily quick glance: menu bar dot + popover is enough.

---

## Related

- [[Tunnel-Monitor-App-Menu-Bar]]
- [[Tunnel-Monitor-App-Settings]]
- [[Tunnel-Monitor-App-Architecture]]
