# Platform visual assets

Original topology illustrations for uvpn platform guides. These are **uvpn-authored** diagrams inspired by vendor administration material—not copied vendor screenshots.

**Display format:** Guides and the wiki embed **`*.png`** files. GitHub Markdown does not reliably render repository-relative **SVG** images (wrong `Content-Type` on `raw.githubusercontent.com`).

**Source format:** Matching **`*.svg`** files remain in this folder for editing; regenerate PNGs after SVG changes:

```bash
cd docs/vpn-solutions/assets
for f in *-architecture.svg; do
  qlmanage -t -s 1200 -o . "${f}"
  mv "${f}.png" "${f%.svg}.png"
done
```

| PNG (embedded in docs) | SVG (editable source) | Platform |
|------------------------|-------------------------|----------|
| [pulse-architecture.png](pulse-architecture.png) | [pulse-architecture.svg](pulse-architecture.svg) | Pulse / Ivanti ISAC |
| [fortinet-architecture.png](fortinet-architecture.png) | [fortinet-architecture.svg](fortinet-architecture.svg) | FortiClient |
| [globalprotect-architecture.png](globalprotect-architecture.png) | [globalprotect-architecture.svg](globalprotect-architecture.svg) | GlobalProtect |
| [cisco-architecture.png](cisco-architecture.png) | [cisco-architecture.svg](cisco-architecture.svg) | Cisco Secure Client |
| [openvpn-architecture.png](openvpn-architecture.png) | [openvpn-architecture.svg](openvpn-architecture.svg) | OpenVPN |
| [wireguard-architecture.png](wireguard-architecture.png) | [wireguard-architecture.svg](wireguard-architecture.svg) | WireGuard |
| [ipsec-architecture.png](ipsec-architecture.png) | [ipsec-architecture.svg](ipsec-architecture.svg) | IPsec / strongSwan |

Referenced from each guide under **Visual reference**. Wiki pages use `raw/main/.../*.png` URLs.
