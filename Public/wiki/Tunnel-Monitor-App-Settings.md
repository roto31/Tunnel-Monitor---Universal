# Settings

[← Hub](Tunnel-Monitor-App)

**Settings** opens from the menu bar popover ([[Tunnel-Monitor-App-Menu-Bar]]). Preferences are stored in **UserDefaults** (not `config.env`).

---

## Options

| Setting | Effect |
|---------|--------|
| **Poll interval** | How often the app re-reads `state.json` (5 / 15 / 30 s) |
| **Show menu bar icon** | Hides `MenuBarExtra` when off (access via Dock if visible) |
| **Show dashboard on launch** | Opens dashboard window at startup |
| **Compact menu bar label** | Shorter menu bar text |

---

## Does not change

- LaunchDaemon interval (always 5 minutes unless you edit the plist)
- SMTP, tunnel IPs, thresholds — use **Configuration** ([[Tunnel-Monitor-App-Configuration-SMTP]] …) or **Edit Config**

---

## Related

- [[Tunnel-Monitor-App-Menu-Bar]]
- [[Tunnel-Monitor-App-Dashboard]]
- [[Tunnel-Monitor-App-Troubleshooting]]
