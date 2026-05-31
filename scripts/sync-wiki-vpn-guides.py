#!/usr/bin/env python3
"""Copy full docs/vpn-solutions guides into .wiki-publish with wiki-local image paths."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS_DIR = ROOT / "docs" / "vpn-solutions"
WIKI_DIR = ROOT / ".wiki-publish"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

GUIDES: list[tuple[str, str]] = [
    ("pulse-ivanti.md", "Pulse-Ivanti.md"),
    ("fortinet-forticlient.md", "Fortinet-FortiClient.md"),
    ("palo-alto-globalprotect.md", "Palo-Alto-GlobalProtect.md"),
    ("cisco-anyconnect.md", "Cisco-AnyConnect.md"),
    ("openvpn.md", "OpenVPN.md"),
    ("wireguard.md", "WireGuard.md"),
    ("ipsec-ikev2.md", "IPsec-IKEv2.md"),
]

ARCH_LINKS: dict[str, str] = {
    "../architecture/pulse-cli-contract.md": "Pulse-CLI-Contract",
    "../architecture/adapter-version-matrix.md": "Adapter-Version-Matrix",
    "../architecture/plugin-adapters.md": "Plugin-Development-Guide",
    "../architecture/research-vpn-platforms.md": "VPN-Research",
}

RAW_ASSET = re.compile(
    r"https://raw\.githubusercontent\.com/roto31/Tunnel-Monitor---Universal/"
    r"main/docs/vpn-solutions/assets/([a-z0-9_-]+\.png)"
)


def transform_body(text: str) -> str:
    text = RAW_ASSET.sub(r"images/\1", text)
    text = re.sub(r"\(assets/([a-z0-9_-]+\.png)\)", r"(images/\1)", text)
    for rel, wiki_page in ARCH_LINKS.items():
        text = text.replace(f"]({rel})", f"]({wiki_page})")
    text = re.sub(
        r"Manifest: \[manifests/([^\]]+)\]\(manifests/[^)]+\)",
        rf"Manifest: [`\1`]({REPO}/blob/main/docs/vpn-solutions/manifests/\1)",
        text,
    )
    return text


def wiki_header(doc_name: str) -> str:
    return (
        f"> **Canonical source (edit in repo):** "
        f"[{doc_name}]({REPO}/blob/main/docs/vpn-solutions/{doc_name}) — "
        f"regenerate this wiki page with `python3 scripts/sync-wiki-vpn-guides.py`.\n\n---\n\n"
    )


def main() -> int:
    if not WIKI_DIR.is_dir():
        print("ERROR: .wiki-publish not found", file=sys.stderr)
        return 1
    images = WIKI_DIR / "images"
    assets = DOCS_DIR / "assets"
    if assets.is_dir():
        images.mkdir(exist_ok=True)
        for png in assets.glob("*-architecture.png"):
            dest = images / png.name
            if not dest.exists() or png.stat().st_mtime > dest.stat().st_mtime:
                dest.write_bytes(png.read_bytes())

    for doc_name, wiki_name in GUIDES:
        src = DOCS_DIR / doc_name
        if not src.is_file():
            print(f"ERROR: missing {src}", file=sys.stderr)
            return 1
        body = transform_body(src.read_text(encoding="utf-8"))
        out = WIKI_DIR / wiki_name
        out.write_text(wiki_header(doc_name) + body, encoding="utf-8")
        print(f"wrote {wiki_name} ({len(body.splitlines())} lines)")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
