#!/usr/bin/env python3
"""Publish docs/security and status-portal to GitHub Wiki."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WIKI = ROOT / ".wiki-publish"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

MAP: list[tuple[str, str]] = [
    ("docs/security/README.md", "Security.md"),
    ("docs/security/nist-portal-architecture.md", "Security-NIST-Architecture.md"),
    ("docs/security/threat-model.md", "Security-Threat-Model.md"),
    ("docs/security/verification.md", "Security-Verification.md"),
    ("docs/security/host-hardening-linux.md", "Security-Linux-Hardening.md"),
    ("docs/security/host-hardening-macos.md", "Security-macOS-Hardening.md"),
    ("docs/deploy/status-portal.md", "Status-Portal.md"),
]

LINKS: dict[str, str] = {
    "../deploy/status-portal.md": "Status-Portal",
    "status-portal.md": "Status-Portal",
    "../security/README.md": "Security",
    "../security/nist-portal-architecture.md": "Security-NIST-Architecture",
    "../security/threat-model.md": "Security-Threat-Model",
    "../security/verification.md": "Security-Verification",
    "../security/host-hardening-linux.md": "Security-Linux-Hardening",
    "../security/host-hardening-macos.md": "Security-macOS-Hardening",
    "nist-portal-architecture.md": "Security-NIST-Architecture",
    "threat-model.md": "Security-Threat-Model",
    "verification.md": "Security-Verification",
    "host-hardening-linux.md": "Security-Linux-Hardening",
    "host-hardening-macos.md": "Security-macOS-Hardening",
    "../security/ctm-portal.csv": f"{REPO}/blob/main/docs/security/ctm-portal.csv",
    "ctm-portal.csv": f"{REPO}/blob/main/docs/security/ctm-portal.csv",
    "../deploy/scheduling.md": "Scheduling",
    "../security/nist-portal-architecture.md": "Security-NIST-Architecture",
    "../security/threat-model.md": "Security-Threat-Model",
    "../security/verification.md": "Security-Verification",
    "../../src/deploy/linux/uvpn-statusd.service": f"{REPO}/blob/main/src/deploy/linux/uvpn-statusd.service",
    "../../src/deploy/statusd/Caddyfile.example": f"{REPO}/blob/main/src/deploy/statusd/Caddyfile.example",
    "../../src/deploy/statusd/nftables-uvpn-statusd.nft.example": (
        f"{REPO}/blob/main/src/deploy/statusd/nftables-uvpn-statusd.nft.example"
    ),
}


def transform(text: str) -> str:
    for rel, wiki in LINKS.items():
        if rel.startswith("http") or rel.endswith(".csv"):
            text = text.replace(f"]({rel})", f"]({wiki})")
        else:
            text = text.replace(f"]({rel})", f"]({wiki})")
    return text


def header(src: str) -> str:
    return (
        f"> **Canonical source:** [{src}]({REPO}/blob/main/{src}) "
        f"— sync via `python3 scripts/sync-wiki-all.py`.\n\n---\n\n"
    )


def main() -> int:
    if not WIKI.is_dir():
        print("ERROR: .wiki-publish missing", file=sys.stderr)
        return 1
    for src_rel, wiki_name in MAP:
        path = ROOT / src_rel
        if not path.is_file():
            print(f"ERROR: missing {path}", file=sys.stderr)
            return 1
        body = transform(path.read_text(encoding="utf-8"))
        out = WIKI / wiki_name
        out.write_text(header(src_rel) + body, encoding="utf-8")
        print(f"wrote {wiki_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
