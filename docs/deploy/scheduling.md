# Scheduling (systemd + LaunchAgent)

Shipped unit files under [`src/deploy/`](../../src/deploy/). Default interval: **300 seconds** (matches `check_interval_sec` default).

## Linux (systemd timer)

```bash
sudo bash src/deploy/linux/install-systemd.sh
```

Files installed:

| File | Role |
|------|------|
| `/etc/systemd/system/uvpn.service` | Oneshot `uvpn check` |
| `/etc/systemd/system/uvpn.timer` | Fires every 5 minutes |

Config directory: `/etc/uvpn/config.json` (`UVPN_CONFIG_DIR=/etc/uvpn`).

Manual install:

```bash
sudo install -m 0644 src/deploy/linux/uvpn.service /etc/systemd/system/
sudo install -m 0644 src/deploy/linux/uvpn.timer /etc/systemd/system/
sudo mkdir -p /etc/uvpn
sudo systemctl daemon-reload
sudo systemctl enable --now uvpn.timer
```

Verify:

```bash
systemctl status uvpn.timer
journalctl -u uvpn.service -n 20
```

## macOS (LaunchAgent)

```bash
bash src/deploy/macos/install-launchagent.sh
```

Installs `~/Library/LaunchAgents/com.universal.uvpn.check.plist` (300s interval).

Config: `~/Library/Application Support/uvpn/config.json`  
Logs: `~/Library/Logs/uvpn-check.log`

Verify:

```bash
launchctl print "gui/$(id -u)/com.universal.uvpn.check"
```

## Requirements

- `uvpn` on PATH (`/usr/local/bin/uvpn` recommended)
- Valid `config.json` in the configured directory
- Poll interval ≥ 30s (project minimum)

See also: [Linux installation](../platform-linux/installation.md), [macOS installation](../platform-macos/installation.md).
