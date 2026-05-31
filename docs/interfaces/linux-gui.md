# Linux GUI (GTK4)

Native GTK4 desktop GUI for popular distributions (Ubuntu, Debian, Fedora).

## Requirements

```bash
# Debian/Ubuntu
sudo apt install python3-gi gir1.2-gtk-4.0

# Fedora
sudo dnf install python3-gobject gtk4

pip install -e ".[dev,linux-gui]"
```

## Launch

```bash
python3 apps/linux/uvpn_gui.py
```

## Behavior

- Reads/writes through `MonitorEngine` (same as CLI).
- Displays last diagnosis, probe summary, and refresh button.
- If PyGObject/GTK4 unavailable: exits with message to use `bash scripts/uvpn-tui`.

## Distribution fallback

| Environment | Recommended interface |
|-------------|----------------------|
| Desktop with GTK4 | `uvpn_gui.py` |
| Server / minimal install | `uvpn-tui` or `uvpn` CLI |
| SSH session | `uvpn-tui` |

Feature parity with CLI/TUI is the design goal; v0.1 GUI is a functional scaffold — explain/preflight via TUI or CLI until expanded.
