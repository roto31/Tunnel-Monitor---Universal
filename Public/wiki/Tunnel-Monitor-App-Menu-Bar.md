# Menu bar popover & actions

[← Hub](Tunnel-Monitor-App)

The **traffic-light dot** opens a popover with live checks, issues, and operator actions. The app does not run pings — it reads `state.json` from the daemon.

![Healthy popover](https://raw.githubusercontent.com/roto31/UniFi-Tunnel-Monitor/main/docs/tunnel-monitor/images/menu-popover-healthy.png)

---

## Status header

| Element | Meaning |
|---------|---------|
| Dot color | Green / yellow / red (see [[Tunnel-Monitor-App-Architecture]]) |
| Title | e.g. **Tunnel UP** / **Tunnel DOWN** |
| Subtitle | Diagnosis + `down_since` when applicable |

---

## Checks list

Rows mirror `checks` in `state.json`:

- Tunnel (`REMOTE_LAN_IP`)
- Remote WAN
- Internet (e.g. `1.1.1.1`)
- DNS (`REMOTE_DDNS` vs `REMOTE_WAN_IP`)

Each row: OK / FAIL and latency when present.

---

## Issues

Bullets from `StatusPresentation` (threshold, dedup, disagreement, etc.).

---

## Actions

| Action | What it does |
|--------|----------------|
| **Setup…** | Opens Configuration window ([[Tunnel-Monitor-App-Configuration-SMTP]] …) |
| **Edit Config** | Opens `config.env` in Terminal (async — avoids popover hang) |
| **Force Check** | `launchctl kickstart` on the daemon |
| **Copy SSH Auth Cmd** | One-time gateway SSH key install |
| **SSH Test** | Verifies dedup SSH |
| **Test Email** | Sends test via `send-email.sh` |
| **Test Notify** | Banner smoke test |
| **Open Dashboard** | [[Tunnel-Monitor-App-Dashboard]] |
| **Settings** | [[Tunnel-Monitor-App-Settings]] |

---

## Launch at login

Footer toggle registers **Login Item** (`SMAppService`). Independent of the LaunchDaemon (daemon still needs `install.sh` / pkg).

---

## UX notes

- Popover uses **inline** feedback (no sheets) so the menu bar does not beach-ball.
- **Setup…** is handled via `AppWindowOpener` on the menu label — see architecture diagram on [[Tunnel-Monitor-App-Architecture]].
