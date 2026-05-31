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
python3 src/gui-linux/uvpn_gui.py
```

Tkinter fallback (no GTK):

```bash
python3 src/gui-linux/uvpn_gui_fallback.py
```

## Behavior

- Tabs: Status, Statistics, Logs, Diagnostics via `MonitorAPI.full_view()`.
- Actions: **Run check**, **Refresh**, **Explain**, **Preflight**, **Adapters** (CLI parity).
- If PyGObject/GTK4 unavailable: use `bash scripts/uvpn-tui` or tkinter fallback.

## Distribution fallback

| Environment | Recommended interface |
|-------------|----------------------|
| Desktop with GTK4 | `src/gui-linux/uvpn_gui.py` |
| Desktop without GTK | `src/gui-linux/uvpn_gui_fallback.py` |
| Server / minimal install | `uvpn-tui` or `uvpn` CLI |
| SSH session | `uvpn-tui` |
