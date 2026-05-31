#!/usr/bin/env python3
"""Run all wiki sync scripts in dependency-safe order."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = [
    "sync-wiki-core.py",
    "sync-wiki-brand.py",
    "sync-wiki-security.py",
    "sync-wiki-platform-diagrams.py",
    "sync-wiki-vpn-guides.py",
    "sync-wiki-troubleshooting.py",
]


def main() -> int:
    for name in SCRIPTS:
        path = ROOT / "scripts" / name
        print(f"=== {name} ===")
        rc = subprocess.call([sys.executable, str(path)], cwd=ROOT)
        if rc != 0:
            return rc
    print("OK: all wiki pages synced to .wiki-publish/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
