#!/usr/bin/env python3
"""Publish docs/brand/*.md to GitHub Wiki."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BRAND = ROOT / "docs" / "brand"
WIKI = ROOT / ".wiki-publish"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

MAP: list[tuple[str, str]] = [
    ("narrative-and-voice.md", "Brand-and-Voice.md"),
    ("messaging-snippets.md", "Brand-Messaging-Snippets.md"),
    ("README.md", "Brand-README.md"),
]

LINKS: dict[str, str] = {
    "../troubleshooting/universal.md": "Troubleshooting-Universal",
    "../troubleshooting/README.md": "Troubleshooting",
    "../vpn-solutions/pulse-ivanti.md": "Pulse-Ivanti",
    "../architecture/system-design.md": "Architecture",
    "../architecture/adapter-version-matrix.md": "Adapter-Version-Matrix",
    "../legacy/Public/docs/troubleshooting.md": "Troubleshooting-Legacy-Public",
    "narrative-and-voice.md": "Brand-and-Voice",
    "messaging-snippets.md": "Brand-Messaging-Snippets",
    "../vpn-solutions/README.md": "VPN-Research",
}


def transform(text: str) -> str:
    for rel, wiki in LINKS.items():
        text = text.replace(f"]({rel})", f"]({wiki})")
    return text


def header(src: str) -> str:
    return (
        f"> **Canonical source:** [{src}]({REPO}/blob/main/docs/brand/{src}) "
        f"— sync via `python3 scripts/sync-wiki-brand.py`.\n\n---\n\n"
    )


def main() -> int:
    if not WIKI.is_dir():
        print("ERROR: .wiki-publish missing", file=sys.stderr)
        return 1
    for src_name, wiki_name in MAP:
        path = BRAND / src_name
        if not path.is_file():
            print(f"ERROR: missing {path}", file=sys.stderr)
            return 1
        body = transform(path.read_text(encoding="utf-8"))
        out = WIKI / wiki_name
        out.write_text(header(src_name) + body, encoding="utf-8")
        print(f"wrote {wiki_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
