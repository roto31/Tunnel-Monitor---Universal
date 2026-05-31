#!/usr/bin/env python3
"""Launch Linux GUI: GTK4 preferred, tkinter generic fallback, TUI message last."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GTK = Path(__file__).resolve().parent / "uvpn_gui.py"
TK = Path(__file__).resolve().parent / "uvpn_gui_fallback.py"


def main() -> int:
    try:
        import gi  # noqa: F401

        gi.require_version("Gtk", "4.0")
        return subprocess.call([sys.executable, str(GTK)])
    except ImportError:
        pass
    try:
        import tkinter  # noqa: F401

        return subprocess.call([sys.executable, str(TK)])
    except ImportError:
        print("No GTK4 or tkinter — use: bash scripts/uvpn-tui", file=sys.stderr)
        return 3


if __name__ == "__main__":
    raise SystemExit(main())
