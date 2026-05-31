#!/usr/bin/env python3
"""Linux GTK4 GUI — full MonitorAPI tabs (status, statistics, logs, diagnostics)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

SRC = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SRC))

from uvpn.api.platform import MonitorAPI  # noqa: E402


def main() -> int:
    try:
        import gi

        gi.require_version("Gtk", "4.0")
        from gi.repository import GLib, Gtk
    except ImportError:
        print("WARN: GTK4 unavailable — try: python3 src/gui-linux/launch_gui.py", file=sys.stderr)
        return 3

    api = MonitorAPI()

    class App(Gtk.Application):
        def do_activate(self) -> None:
            win = Gtk.ApplicationWindow(application=self, title="Universal VPN Monitor", default_width=720, default_height=520)
            stack = Gtk.Stack()
            stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)
            switcher = Gtk.StackSwitcher(stack=stack)
            switcher.set_halign(Gtk.Align.CENTER)

            self.views: dict[str, Gtk.TextView] = {}
            for name in ("Status", "Statistics", "Logs", "Diagnostics"):
                tv = Gtk.TextView(editable=False, monospace=True, wrap_mode=Gtk.WrapMode.WORD)
                scroll = Gtk.ScrolledWindow(child=tv, vexpand=True)
                stack.add_named(scroll, name)
                self.views[name] = tv

            check_btn = Gtk.Button(label="Run check")
            check_btn.connect("clicked", lambda *_: self._run_check())
            refresh_btn = Gtk.Button(label="Refresh")
            refresh_btn.connect("clicked", lambda *_: self._refresh())
            explain_btn = Gtk.Button(label="Explain")
            explain_btn.connect("clicked", lambda *_: self._show_text("Explain", api.explain()))
            preflight_btn = Gtk.Button(label="Preflight")
            preflight_btn.connect("clicked", lambda *_: self._show_preflight())
            adapters_btn = Gtk.Button(label="Adapters")
            adapters_btn.connect("clicked", lambda *_: self._show_text("Adapters", "\n".join(api.list_adapters())))

            bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8, halign=Gtk.Align.END)
            bar.append(adapters_btn)
            bar.append(preflight_btn)
            bar.append(explain_btn)
            bar.append(refresh_btn)
            bar.append(check_btn)

            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8, margin_top=12, margin_bottom=12, margin_start=12, margin_end=12)
            box.append(switcher)
            box.append(stack)
            box.append(bar)
            win.set_child(box)
            win.present()
            self._refresh()

        def _set(self, key: str, payload: object) -> None:
            tv = self.views[key]
            buf = tv.get_buffer()
            text = json.dumps(payload, indent=2) if not isinstance(payload, str) else payload
            buf.set_text(text)

        def _run_check(self) -> None:
            api.run_check()
            self._refresh()

        def _refresh(self) -> None:
            view = api.full_view()
            self._set("Status", view.status)
            self._set("Statistics", view.statistics)
            self._set("Logs", "\n".join(view.logs))
            self._set("Diagnostics", view.diagnostics)

        def _show_text(self, title: str, body: str) -> None:
            win = Gtk.Window(title=title, transient_for=None, modal=True, default_width=520, default_height=360)
            tv = Gtk.TextView(editable=False, monospace=True, wrap_mode=Gtk.WrapMode.WORD)
            tv.get_buffer().set_text(body)
            win.set_child(Gtk.ScrolledWindow(child=tv, margin_top=8, margin_bottom=8, margin_start=8, margin_end=8))
            win.present()

        def _show_preflight(self) -> None:
            fails, lines = api.preflight()
            body = "\n".join(lines) + f"\n\nResult: {len(lines) - fails} ok, {fails} failed"
            self._show_text("Preflight", body)

    app = App(application_id="com.universal.vpnmonitor")
    app.run(None)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
