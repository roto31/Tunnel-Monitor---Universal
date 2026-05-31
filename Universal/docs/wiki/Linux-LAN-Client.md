# Linux LAN Client

**Path:** `Public/linux/`

**Install root:** `/opt/tunnel-monitor/`

## Install

```bash
cd Public/linux
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env
tunnel-check --test-email
tunnel-check --ssh-test
sudo tunnel-check --check-now
sudo bash verify.sh
```

## Dependencies

```bash
# Debian/Ubuntu
sudo apt install jq curl dnsutils openssh-client iputils-ping
```

## Differences from Mac

| Feature | Mac | Linux |
|---------|-----|-------|
| Scheduler | launchd | systemd timer |
| Desktop banner | osascript | **stub** (log only) |
| Ping timeout | BSD (ms) | GNU (seconds) |
| Awareness | email + app + SwiftBar | email + optional tray app |

## Tray app

Cross-platform reader: `Public/tray-app/` (reads `state.json`, no checks).

## CLI

Same as Mac plus:

```bash
tunnel-check --ssh-test
tunnel-check --status    # systemctl timer status
```
