# Universal VPN Monitor (uvpn)

Platform-agnostic **point-to-point VPN monitoring** for Linux servers and macOS desktops.

Monitor **any** site-to-site or routed P2P VPN — OpenVPN, WireGuard, IPsec/IKEv2, Cisco AnyConnect, or unknown types via generic reachability probes. One Python engine powers **CLI**, **universal terminal (TUI)**, **Linux GTK GUI**, and **macOS Swift GUI** with equivalent capabilities.

> **Legacy:** The bash UniFi/site-specific stack (`legacy/Public/`, `legacy/vendor/core/`) is archived under [`legacy/`](legacy/README.md). It is **not** the Universal product.

## Quick start

```bash
git clone https://github.com/roto31/Tunnel-Monitor---Universal.git
cd Tunnel-Monitor---Universal
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
uvpn init-config
${EDITOR:-nano} ~/.config/uvpn/config.json
uvpn preflight && uvpn check && uvpn explain
```

Interactive terminal menu:

```bash
bash scripts/uvpn-tui
```

## Interfaces

| Interface | Command | Technology |
|-----------|---------|------------|
| CLI | `uvpn check`, `uvpn status`, `uvpn explain` | Python 3.11+ |
| Universal terminal | `bash scripts/uvpn-tui` | Bash menu → Python engine |
| Linux GUI | `python3 apps/linux/uvpn_gui.py` | GTK4; falls back to TUI |
| macOS GUI | `apps/macos/UniversalVPNMonitor` | Swift menu bar; reads shared `state.json` |

All interfaces use **`uvpn.core.engine.MonitorEngine`**. GUIs read `~/.config/uvpn/state.json` written atomically by the engine.

## Supported VPN adapters (v0.1)

| `vpn_type` | Adapter | Verification source |
|------------|---------|---------------------|
| `generic` | ICMP/DDNS reachability only | Any routed P2P VPN |
| `openvpn` | Management socket / process | [OpenVPN management interface](https://openvpn.net/community-docs/management-interface.html) |
| `wireguard` | `wg show` | [wg(8)](https://manpages.debian.org/bookworm/wireguard-tools/wg.8.en.html) |
| `ipsec` / `ikev2` | `swanctl` or `ipsec` | [strongSwan swanctl](https://docs.strongswan.org/docs/latest/swanctl/swanctl.html) |
| `cisco_anyconnect` | `vpn state` CLI | [Cisco Secure Client admin guide](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html) |

Roadmap: FortiClient, GlobalProtect, Pulse — see [architecture](docs/architecture.md#7-extensibility-roadmap).

## Repository layout

```
├── uvpn/              Python package (engine, adapters, CLI)
├── apps/
│   ├── linux/         GTK4 GUI
│   └── macos/         Swift menu bar app
├── scripts/           uvpn wrapper, uvpn-tui
├── docs/              Architecture, research, platform & adapter guides
├── tests/
├── wiki/              GitHub wiki source
├── legacy/            Archived bash tunnel-monitor v2 (UniFi-oriented)
└── .github/workflows/ CI and release automation
```

## Documentation

| Topic | Path |
|-------|------|
| Architecture (Mermaid) | [docs/architecture.md](docs/architecture.md) |
| VPN platform research (cited) | [docs/research/vpn-platforms.md](docs/research/vpn-platforms.md) |
| Linux install | [docs/platforms/linux/install.md](docs/platforms/linux/install.md) |
| macOS install | [docs/platforms/macos/install.md](docs/platforms/macos/install.md) |
| CLI / TUI / GUI | [docs/interfaces/](docs/interfaces/) |
| Per-VPN setup | [docs/adapters/](docs/adapters/) |
| Troubleshooting | [docs/troubleshooting.md](docs/troubleshooting.md) |
| Wiki | [GitHub Wiki](https://github.com/roto31/Tunnel-Monitor---Universal/wiki) |
| Legacy bash monitor | [legacy/README.md](legacy/README.md) |

## Development

```bash
pip install -e ".[dev]"
pytest -q
bash scripts/uvpn-tui
```

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Releases

uvpn releases: [GitHub Releases](https://github.com/roto31/Tunnel-Monitor---Universal/releases) — see [RELEASES.md](RELEASES.md).

Legacy macOS `.pkg` builds (bash stack): [legacy/RELEASES.md](legacy/RELEASES.md).

## License

MIT — see [LICENSE](LICENSE).
