#!/usr/bin/env python3
"""Publish docs/wiki/*.md to GitHub Wiki core pages."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "docs" / "wiki"
WIKI = ROOT / ".wiki-publish"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

# source filename under docs/wiki/ -> wiki filename
MAP: list[tuple[str, str]] = [
    ("Home.md", "Home.md"),
    ("Getting-Started.md", "Getting-Started.md"),
    ("Architecture.md", "Architecture.md"),
    ("_Sidebar.md", "_Sidebar.md"),
    ("CLI.md", "CLI.md"),
    ("Scheduling.md", "Scheduling.md"),
    ("Diagnoses-and-Alerts.md", "Diagnoses-and-Alerts.md"),
    ("Platform-API.md", "Platform-API.md"),
]


def header(src_rel: str) -> str:
    return (
        f"> **Canonical source:** [{src_rel}]({REPO}/blob/main/{src_rel}) "
        f"— sync via `python3 scripts/sync-wiki-all.py`.\n\n---\n\n"
    )


def main() -> int:
    if not WIKI.is_dir():
        print("ERROR: .wiki-publish missing", file=sys.stderr)
        return 1
    for src_name, wiki_name in MAP:
        path = SRC_DIR / src_name
        if not path.is_file():
            print(f"ERROR: missing {path}", file=sys.stderr)
            return 1
        rel = f"docs/wiki/{src_name}"
        body = path.read_text(encoding="utf-8")
        out = WIKI / wiki_name
        out.write_text(header(rel) + body, encoding="utf-8")
        print(f"wrote {wiki_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
