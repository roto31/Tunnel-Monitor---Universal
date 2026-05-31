# Universal terminal application (TUI)

Shell-based interactive menu for environments without GUI — routers, SSH sessions, serial consoles, headless servers.

Inspired by operator-friendly terminal UIs (e.g. UniFi-style menus): numbered options, no memorized flags required.

## Launch

```bash
bash scripts/uvpn-tui
```

Requires Python 3.11+ and the `uvpn` package (editable install or `.venv`).

## Menu actions

| Option | Action |
|--------|--------|
| Run check | Calls `uvpn check` |
| Show status | Calls `uvpn status` |
| Explain last diagnosis | Calls `uvpn explain` |
| Preflight | Calls `uvpn preflight` |
| Edit config | Opens `$EDITOR` on `~/.config/uvpn/config.json` |
| List adapters | Calls `uvpn adapters` |

All actions invoke the **same Python engine** as the CLI — no duplicated probe logic.

## Router / embedded use

Copy the repo or install uvpn on the gateway, then:

```bash
ln -sf /opt/uvpn/scripts/uvpn-tui /usr/local/bin/uvpn-tui
uvpn-tui
```

For scheduled checks, use cron or systemd timer calling `uvpn check` directly; use TUI for ad-hoc operator tasks.

## Fallback on Linux

If GTK GUI packages are missing, `src/gui-linux/uvpn_gui.py` prints a message and suggests `uvpn-tui`.
