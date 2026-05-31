#!/usr/bin/env python3
"""Publish docs/architecture/vpn-platform-diagrams.md to wiki VPN-Platform-Diagrams.md."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "docs" / "architecture" / "vpn-platform-diagrams.md"
WIKI = ROOT / ".wiki-publish" / "VPN-Platform-Diagrams.md"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

LINKS: dict[str, str] = {
    "../vpn-solutions/openvpn.md": "OpenVPN",
    "../vpn-solutions/wireguard.md": "WireGuard",
    "../vpn-solutions/ipsec-ikev2.md": "IPsec-IKEv2",
    "../vpn-solutions/cisco-anyconnect.md": "Cisco-AnyConnect",
    "../vpn-solutions/fortinet-forticlient.md": "Fortinet-FortiClient",
    "../vpn-solutions/palo-alto-globalprotect.md": "Palo-Alto-GlobalProtect",
    "../vpn-solutions/pulse-ivanti.md": "Pulse-Ivanti",
    "../vpn-solutions/": "VPN-Research",
    "../vpn-solutions/assets/README.md": "images",
    "system-design.md": "Architecture",
    "../security/nist-portal-architecture.md": "Security-NIST-Architecture",
    "../deploy/status-portal.md": "Status-Portal",
}


def transform(text: str) -> str:
    text = text.replace(
        "# VPN platform diagrams (uvpn)",
        "# VPN platform diagrams",
    )
    for rel, wiki in LINKS.items():
        text = text.replace(f"]({rel})", f"]({wiki})")
    text = re.sub(
        r"\[`([^`]+)`\]\(images/([^)]+)\)",
        r"[\1](images/\2)",
        text,
    )
    return text


def main() -> int:
    if not SRC.is_file():
        print(f"ERROR: missing {SRC}", file=sys.stderr)
        return 1
    header = (
        f"> **Canonical source:** [vpn-platform-diagrams.md]"
        f"({REPO}/blob/main/docs/architecture/vpn-platform-diagrams.md) "
        f"— sync via `python3 scripts/sync-wiki-platform-diagrams.py`.\n\n---\n\n"
    )
    body = transform(SRC.read_text(encoding="utf-8"))
    WIKI.write_text(header + body, encoding="utf-8")
    print(f"wrote {WIKI.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
