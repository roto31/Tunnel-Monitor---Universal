# Linux installation

## Requirements

- Python 3.11+
- `ping`, `dig`
- Optional: `python3-gi`, `gir1.2-gtk-4.0` for GUI

## Install

```bash
cd universal-vpn-monitor
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev,linux-gui]"
sudo ln -sf "$(pwd)/scripts/uvpn" /usr/local/bin/uvpn
```

## Configure

```bash
uvpn init-config
${EDITOR:-nano} ~/.config/uvpn/config.json
```

Example for WireGuard site-to-site:

```json
{
  "vpn_type": "wireguard",
  "wireguard_interface": "wg0",
  "remote_lan_ip": "192.168.10.1",
  "remote_wan_ip": "203.0.113.10",
  "remote_ddns": "remote.example.com",
  "failure_threshold": 3,
  "check_interval_sec": 300
}
```

## Run

```bash
uvpn preflight
uvpn check
bash scripts/uvpn-tui
python3 apps/linux/uvpn_gui.py   # or fallback to TUI if no GTK
```

## systemd timer (optional)

```ini
[Unit]
Description=Universal VPN Monitor check

[Timer]
OnBootSec=2min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
```

```ini
[Service]
Type=oneshot
ExecStart=/usr/local/bin/uvpn check
```

## Distribution notes

| Distro | GTK GUI packages |
|--------|------------------|
| Ubuntu 22.04+ | `apt install python3-gi gir1.2-gtk-4.0` |
| Fedora 38+ | `dnf install python3-gobject gtk4` |
| Debian 12+ | same as Ubuntu |

If GUI packages are unavailable, use **`uvpn-tui`** — full engine parity.
