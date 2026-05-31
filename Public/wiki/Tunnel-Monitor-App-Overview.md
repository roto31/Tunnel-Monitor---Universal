# Tunnel Monitor.app — overview

[← Hub](Tunnel-Monitor-App)

## Why it exists

Site-to-site VPNs (**OpenVPN** or **IPsec** on UniFi gateways) can fail silently from the LAN: the router may show “connected” while remote traffic does not flow. Operators used **bash + SwiftBar**; **Tunnel Monitor.app** adds a native GUI for status, configuration, and actions.

The app **does not replace** `monitor.sh`. Pings, DNS, SSH dedup, email, and banners remain in the LaunchDaemon.

---

## What the stack does

| Capability | Performed by |
|------------|--------------|
| Ping tunnel / WAN / internet / DNS | `monitor.sh` |
| Write `state.json` | `monitor.sh` |
| Email + banner alerts | `send-email.sh` / `notify.sh` |
| Traffic-light UI, issues list | Tunnel Monitor.app |
| Edit `config.env` via GUI | Configuration window |
| Force check now | App → `launchctl kickstart` |

Transport is **agnostic** — no OpenVPN process inspection. See [[OpenVPN-Site-to-Site-Migration]] if you moved from IPsec.

---

## What the GUI does not do

- Arbitrary VPNs (one site pair per `config.env`).
- In-app ping or polling of the network (only reads JSON).
- Store SMTP password outside `config.env`.
- Replace the gateway-side monitor.

---

## GUI features

- **Menu bar dot** — green / yellow / red.
- **Menu bar popover** — checks, dedup, actions → [[Tunnel-Monitor-App-Menu-Bar]].
- **Configuration window** — four sections → [[Tunnel-Monitor-App-Configuration-SMTP]] and siblings.
- **Dashboard** — optional resizable window → [[Tunnel-Monitor-App-Dashboard]].
- **Settings** — display toggles, poll interval → [[Tunnel-Monitor-App-Settings]].
- **Launch at login** — footer toggle (`SMAppService`).

---

## Quick paths

**Beginner:** Install pkg → open app → complete Configuration → SSH Test → Test Email/Notify.

**Operator:** Watch menu bar dot; **Setup…** for config changes; **Force Check** after No-IP updates.

**Advanced:** `install.sh`, `tunnel-check`, [[macOS-Monitor]], [[Tunnel-Monitor-App-Architecture]].
