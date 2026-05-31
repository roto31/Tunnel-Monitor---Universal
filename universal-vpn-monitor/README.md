# Universal VPN Monitor (uvpn)

Platform-agnostic **point-to-point VPN monitoring** for Linux servers and macOS desktops.

This is the **new Universal product**. It is **not** the legacy bash `Public/` UniFi-oriented monitor.

## Three interfaces, one engine

| Interface | Path | Technology |
|-----------|------|------------|
| CLI | `scripts/uvpn` | Python 3.11+ |
| Universal terminal | `scripts/uvpn-tui` | Bash menu → Python engine |
| Linux GUI | `apps/linux/uvpn_gui.py` | GTK4 (PyGObject); falls back to TUI |
| macOS GUI | `apps/macos/UniversalVPNMonitor/` | Swift — reads shared `state.json` |

All interfaces call **`uvpn.core.engine.MonitorEngine`**.

## Quick start

```bash
cd universal-vpn-monitor
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
uvpn init-config
# edit ~/.config/uvpn/config.json — set vpn_type, remote_lan_ip, remote_wan_ip
uvpn preflight
uvpn check
uvpn explain
bash scripts/uvpn-tui
```

## Supported VPN adapters (v0.1)

| vpn_type | Adapter | Notes |
|----------|---------|-------|
| `generic` | Reachability only | Works with **any** routed P2P VPN |
| `openvpn` | Management socket / process | [OpenVPN management interface](https://openvpn.net/community-docs/management-interface.html) |
| `wireguard` | `wg show` | [wg(8) man page](https://manpages.debian.org/bookworm/wireguard-tools/wg.8.en.html) |
| `ipsec` / `ikev2` | `swanctl` or `ipsec` | [strongSwan swanctl](https://docs.strongswan.org/docs/latest/swanctl/swanctl.html) |
| `cisco_anyconnect` | `vpn state` CLI | [Cisco Secure Client admin guide](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html) |

Enterprise clients (FortiClient, GlobalProtect) are **planned adapters** — use `generic` until implemented.

## Documentation

- [Architecture](docs/architecture.md)
- [VPN platform research (cited)](docs/research/vpn-platforms.md)
- [Linux install](docs/platforms/linux/install.md)
- [macOS install](docs/platforms/macos/install.md)

## Legacy stack

The repository root `Public/`, `vendor/core/` (bash), and `adapters/unifi-gateway/` remain as **legacy site-specific** tooling. Do not confuse with uvpn.
