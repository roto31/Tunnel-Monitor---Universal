# Linux installation

## Requirements

- Python 3.11+
- `ping`, `dig`
- Optional: `python3-gi`, `gir1.2-gtk-4.0` for GUI

## Install

```bash
cd Tunnel-Monitor---Universal   # repo root
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
python3 src/gui-linux/uvpn_gui.py   # or fallback to TUI if no GTK
```

## systemd timer

Shipped unit files live in `src/deploy/linux/`:

```bash
sudo bash src/deploy/linux/install-systemd.sh
```

This installs `uvpn.service` (oneshot `uvpn check`) and `uvpn.timer` (every 5 minutes). Config directory: `/etc/uvpn/config.json` (`UVPN_CONFIG_DIR=/etc/uvpn`).

Manual install:

```bash
sudo install -m 0644 src/deploy/linux/uvpn.service /etc/systemd/system/
sudo install -m 0644 src/deploy/linux/uvpn.timer /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable --now uvpn.timer
```

## Distribution notes

| Distro | GTK GUI packages |
|--------|------------------|
| Ubuntu 22.04+ | `apt install python3-gi gir1.2-gtk-4.0` |
| Fedora 38+ | `dnf install python3-gobject gtk4` |
| Debian 12+ | same as Ubuntu |

If GUI packages are unavailable, use **`uvpn-tui`** — full engine parity.

## Optional status portal (private network)

```bash
pip install -e ".[portal]"
sudo bash src/deploy/linux/install-statusd.sh
sudo systemctl enable --now uvpn-statusd
```

TLS and firewall: [../security/host-hardening-linux.md](../security/host-hardening-linux.md). Overview: [../deploy/status-portal.md](../deploy/status-portal.md).
