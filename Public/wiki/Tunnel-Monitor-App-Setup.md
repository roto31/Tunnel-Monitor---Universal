# Tunnel Monitor.app — setup & installation

[← Hub](Tunnel-Monitor-App)

## Prerequisites

- macOS **14+** for the GUI; **12+** for LaunchDaemon scripts.
- Homebrew `jq` (installer can install).
- SMTP on port **587**.
- Optional gateway monitor for dedup — [[Architecture]].

Configure placeholders per [[Placeholders-Reference]].

---

## Path A — `.pkg` (recommended)

1. Download [GitHub Releases](https://github.com/roto31/UniFi-Tunnel-Monitor/releases) `Tunnel-Monitor-*.pkg`.
2. Install (admin password).
3. Open `/Applications/Tunnel Monitor.app`.
4. Complete **Configuration** window (or **Setup…** later).
5. Popover smoke test: **Copy SSH Auth Cmd**, **SSH Test**, **Test Email**, **Test Notify**, **Force Check**.

| Path | Purpose |
|------|---------|
| `/Applications/Tunnel Monitor.app` | GUI |
| `/opt/tunnel-monitor/` | Daemon + config |
| `/Library/LaunchDaemons/com.example.tunnel-monitor.plist` | 5 min interval |
| `/usr/local/bin/tunnel-check` | CLI |

---

## Path B — `install.sh`

```bash
git clone https://github.com/roto31/UniFi-Tunnel-Monitor.git
cd UniFi-Tunnel-Monitor/mac
sudo bash install.sh
sudo vi /opt/tunnel-monitor/config.env
tunnel-check --test-email
```

Build GUI from clone: see [[Build-and-Release]].

---

## Configuration window (next steps)

After install, configure each section:

1. [[Tunnel-Monitor-App-Configuration-SMTP]]
2. [[Tunnel-Monitor-App-Configuration-Topology]]
3. [[Tunnel-Monitor-App-Configuration-Gateway-SSH]]
4. [[Tunnel-Monitor-App-Configuration-Tuning]]

Open via **Setup…** or first launch. **Save** requires admin password.

---

## Notifications

Grant **System Settings → Notifications** for Script Editor / osascript after **Test Notify**.

---

## Daily use

[[Tunnel-Monitor-App-Menu-Bar]]
