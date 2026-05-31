#!/usr/bin/env python3
"""Generic tkinter fallback GUI — all monitoring capabilities via MonitorAPI."""
from __future__ import annotations

import json
import sys
import tkinter as tk
from tkinter import scrolledtext, ttk

ROOT = Path = __import__("pathlib").Path
SRC = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SRC))

from uvpn.api.platform import MonitorAPI  # noqa: E402


class UvpnTkApp:
    def __init__(self) -> None:
        self.api = MonitorAPI()
        self.root = tk.Tk()
        self.root.title("Universal VPN Monitor (fallback GUI)")
        self.root.geometry("640x480")
        nb = ttk.Notebook(self.root)
        nb.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
        self.status_text = scrolledtext.ScrolledText(nb, wrap=tk.WORD, height=12)
        self.stats_text = scrolledtext.ScrolledText(nb, wrap=tk.WORD, height=12)
        self.logs_text = scrolledtext.ScrolledText(nb, wrap=tk.WORD, height=12)
        self.diag_text = scrolledtext.ScrolledText(nb, wrap=tk.WORD, height=12)
        nb.add(self.status_text, text="Status")
        nb.add(self.stats_text, text="Statistics")
        nb.add(self.logs_text, text="Logs")
        nb.add(self.diag_text, text="Diagnostics")
        bar = ttk.Frame(self.root)
        bar.pack(fill=tk.X, padx=8, pady=4)
        ttk.Button(bar, text="Run check", command=self.run_check).pack(side=tk.LEFT, padx=4)
        ttk.Button(bar, text="Refresh", command=self.refresh).pack(side=tk.LEFT, padx=4)
        self.refresh()

    def _set(self, widget: scrolledtext.ScrolledText, data: object) -> None:
        widget.delete("1.0", tk.END)
        widget.insert(tk.END, json.dumps(data, indent=2) if not isinstance(data, str) else data)

    def run_check(self) -> None:
        snap = self.api.run_check()
        self._set(self.status_text, snap.to_dict())
        self.refresh()

    def refresh(self) -> None:
        view = self.api.full_view()
        self._set(self.status_text, view.status)
        self._set(self.stats_text, view.statistics)
        self._set(self.logs_text, "\n".join(view.logs))
        self._set(self.diag_text, view.diagnostics)

    def run(self) -> None:
        self.root.mainloop()


def main() -> int:
    UvpnTkApp().run()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
