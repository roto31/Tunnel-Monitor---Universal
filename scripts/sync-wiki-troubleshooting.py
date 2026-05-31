#!/usr/bin/env python3
"""Publish docs/troubleshooting/*.md to GitHub Wiki pages."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs" / "troubleshooting"
WIKI = ROOT / ".wiki-publish"
REPO = "https://github.com/roto31/Tunnel-Monitor---Universal"

# source filename -> wiki page name (without .md)
MAP: list[tuple[str, str]] = [
    ("README.md", "Troubleshooting"),
    ("universal.md", "Troubleshooting-Universal"),
    ("openvpn.md", "Troubleshooting-OpenVPN"),
    ("wireguard.md", "Troubleshooting-WireGuard"),
    ("ipsec-ikev2.md", "Troubleshooting-IPsec-IKEv2"),
    ("cisco-anyconnect.md", "Troubleshooting-Cisco-AnyConnect"),
    ("fortinet-forticlient.md", "Troubleshooting-Fortinet"),
    ("palo-alto-globalprotect.md", "Troubleshooting-GlobalProtect"),
    ("pulse-ivanti.md", "Troubleshooting-Pulse-Ivanti"),
    ("generic.md", "Troubleshooting-Generic"),
]

LINKS: dict[str, str] = {
    "../vpn-solutions/": "VPN-Setup-Guides",
    "../architecture/pulse-cli-contract.md": "Pulse-CLI-Contract",
    "../architecture/adapter-version-matrix.md": "Adapter-Version-Matrix",
    "../legacy/Public/docs/troubleshooting.md": "Troubleshooting-Legacy-Public",
    "../deploy/scheduling.md": "Scheduling",
    "../platform-linux/gui-setup.md": "Linux-GUI",
    "universal.md": "Troubleshooting-Universal",
    "README.md": "Troubleshooting",
    "openvpn.md": "Troubleshooting-OpenVPN",
    "wireguard.md": "Troubleshooting-WireGuard",
    "ipsec-ikev2.md": "Troubleshooting-IPsec-IKEv2",
    "cisco-anyconnect.md": "Troubleshooting-Cisco-AnyConnect",
    "fortinet-forticlient.md": "Troubleshooting-Fortinet",
    "palo-alto-globalprotect.md": "Troubleshooting-GlobalProtect",
    "pulse-ivanti.md": "Troubleshooting-Pulse-Ivanti",
    "generic.md": "Troubleshooting-Generic",
}

PRODUCT_GUIDES: dict[str, str] = {
    "../vpn-solutions/openvpn.md": "OpenVPN",
    "../vpn-solutions/wireguard.md": "WireGuard",
    "../vpn-solutions/ipsec-ikev2.md": "IPsec-IKEv2",
    "../vpn-solutions/cisco-anyconnect.md": "Cisco-AnyConnect",
    "../vpn-solutions/fortinet-forticlient.md": "Fortinet-FortiClient",
    "../vpn-solutions/palo-alto-globalprotect.md": "Palo-Alto-GlobalProtect",
    "../vpn-solutions/pulse-ivanti.md": "Pulse-Ivanti",
    "../vpn-solutions/README.md": "VPN-Research",
}


def transform(text: str, src_name: str) -> str:
    for rel, wiki in PRODUCT_GUIDES.items():
        text = text.replace(f"]({rel})", f"]({wiki})")
        text = text.replace(f"](../vpn-solutions/{rel.split('/')[-1]})", f"]({wiki})")
    for rel, wiki in LINKS.items():
        if rel.startswith("../"):
            text = text.replace(f"]({rel})", f"]({wiki})")
        else:
            text = re.sub(
                rf"\]\({re.escape(rel)}\)",
                f"]({wiki})",
                text,
            )
    text = text.replace(
        "](../troubleshooting.md)",
        f"]({REPO}/blob/main/docs/troubleshooting.md)",
    )
    text = re.sub(
        r"\]\(\.\./troubleshooting/([^)]+)\)",
        lambda m: f"](Troubleshooting-{m.group(1).replace('.md','').replace('palo-alto-globalprotect','GlobalProtect').replace('pulse-ivanti','Pulse-Ivanti').replace('fortinet-forticlient','Fortinet').replace('cisco-anyconnect','Cisco-AnyConnect').replace('ipsec-ikev2','IPsec-IKEv2').replace('openvpn','OpenVPN').replace('wireguard','WireGuard').replace('generic','Generic').replace('universal','Universal').replace('README','')})"
        if m.group(1) != "README.md"
        else "](Troubleshooting)",
        text,
    )
    # Simpler: explicit replacements
    repl = {
        "](../troubleshooting/universal.md)": "](Troubleshooting-Universal)",
        "](../troubleshooting/README.md)": "](Troubleshooting)",
        "](../troubleshooting/openvpn.md)": "](Troubleshooting-OpenVPN)",
        "](../troubleshooting/wireguard.md)": "](Troubleshooting-WireGuard)",
        "](../troubleshooting/ipsec-ikev2.md)": "](Troubleshooting-IPsec-IKEv2)",
        "](../troubleshooting/cisco-anyconnect.md)": "](Troubleshooting-Cisco-AnyConnect)",
        "](../troubleshooting/fortinet-forticlient.md)": "](Troubleshooting-Fortinet)",
        "](../troubleshooting/palo-alto-globalprotect.md)": "](Troubleshooting-GlobalProtect)",
        "](../troubleshooting/pulse-ivanti.md)": "](Troubleshooting-Pulse-Ivanti)",
        "](../troubleshooting/generic.md)": "](Troubleshooting-Generic)",
        "(universal.md)": "(Troubleshooting-Universal)",
        "(README.md)": "(Troubleshooting)",
    }
    for old, new in repl.items():
        text = text.replace(old, new)
    return text


def header(src: str, wiki_page: str) -> str:
    return (
        f"> **Canonical source:** [{src}]({REPO}/blob/main/docs/troubleshooting/{src}) "
        f"— sync via `python3 scripts/sync-wiki-troubleshooting.py`.\n\n---\n\n"
    )


def main() -> int:
    if not WIKI.is_dir():
        print("ERROR: .wiki-publish missing", file=sys.stderr)
        return 1
    for src_name, wiki_page in MAP:
        path = DOC / src_name
        if not path.is_file():
            print(f"ERROR: missing {path}", file=sys.stderr)
            return 1
        body = transform(path.read_text(encoding="utf-8"), src_name)
        out = WIKI / f"{wiki_page}.md"
        out.write_text(header(src_name, wiki_page) + body, encoding="utf-8")
        print(f"wrote {wiki_page}.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
