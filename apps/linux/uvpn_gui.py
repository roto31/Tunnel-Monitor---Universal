#!/usr/bin/env python3
"""Linux GTK4 GUI for uvpn — falls back to TUI message if PyGObject unavailable."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
UVPN = ROOT / "scripts" / "uvpn"
STATE = Path.home() / ".config" / "uvpn" / "state.json"


def run_check() -> dict | None:
    subprocess.run(["bash", str(UVPN), "check"], check=False)
    if STATE.is_file():
        return json.loads(STATE.read_text(encoding="utf-8"))
    return None


def main() -> int:
    try:
        import gi

        gi.require_version("Gtk", "4.0")
        from gi.repository import GLib, Gtk
    except ImportError:
        print("WARN: GTK4/PyGObject not available — use: bash scripts/uvpn-tui", file=sys.stderr)
        return 3

    class App(Gtk.Application):
        def do_activate(self) -> None:
            win = Gtk.ApplicationWindow(application=self, title="Universal VPN Monitor")
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8, margin_top=12, margin_bottom=12, margin_start=12, margin_end=12)
            self.label = Gtk.Label(label="Loading…")
            btn = Gtk.Button(label="Run check")
            btn.connect("clicked", lambda *_: self._refresh())
            box.append(self.label)
            box.append(btn)
            win.set_child(box)
            win.present()
            GLib.timeout_add_seconds(1, self._refresh_silent)
            self._refresh_silent()

        def _refresh_silent(self) -> bool:
            if STATE.is_file():
                data = json.loads(STATE.read_text(encoding="utf-8"))
                self.label.set_text(
                    f"{data.get('diagnosis')} | {data.get('traffic_light')} | failures={data.get('failure_count')}"
                )
            return False

        def _refresh(self) -> None:
            data = run_check()
            if data:
                self.label.set_text(
                    f"{data.get('diagnosis')} | {data.get('traffic_light')} | failures={data.get('failure_count')}"
                )
            else:
                self.label.set_text("No state — configure ~/.config/uvpn/config.json")

    app = App(application_id="com.universal.vpnmonitor")
    app.run(None)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
