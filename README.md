# Universal VPN Monitor (uvpn)

Platform-agnostic **point-to-point VPN monitoring** for Linux servers and macOS desktops.

One Python **MonitorEngine** + **MonitorAPI** powers four equivalent interfaces: **CLI**, **universal terminal**, **Linux GUI** (GTK4 + tkinter fallback), **macOS Swift GUI** (Liquid Glass on macOS 26).

> **Version note:** `0.2.0` was a development pre-release. **1.0.0** is the first production release — enterprise adapters (Fortinet, GlobalProtect, Pulse) are fixture-validated against vendor documentation, and scheduling unit files ship under `src/deploy/`.

## Quick start

```bash
git clone https://github.com/roto31/Tunnel-Monitor---Universal.git
cd Tunnel-Monitor---Universal
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
uvpn init-config
uvpn preflight && uvpn check
uvpn statistics && uvpn diagnostics
bash scripts/uvpn-tui
```

## Repository structure

```
src/
  uvpn/           Core engine, adapters, MonitorAPI
  cli/            Shell CLI (uvpn)
  terminal-app/   Universal terminal menu (uvpn-tui)
  gui-linux/      GTK4 + tkinter fallback
  gui-macos/      Swift menu bar app
  deploy/         systemd timer + LaunchAgent installers
docs/
  architecture/   System design, Mermaid diagrams, cited research
  platform-linux/ platform-macos/
  vpn-solutions/  Per-VPN guides with source citations
legacy/           Archived bash monitor (not Universal product)
```

## Supported VPN adapters

| vpn_type | Status | Guide |
|----------|--------|-------|
| `generic` | Production | Any routed P2P VPN |
| `openvpn` | Production | [docs/vpn-solutions/openvpn.md](docs/vpn-solutions/openvpn.md) |
| `wireguard` | Production | [docs/vpn-solutions/wireguard.md](docs/vpn-solutions/wireguard.md) |
| `ipsec` / `ikev2` | Production | [docs/vpn-solutions/ipsec-ikev2.md](docs/vpn-solutions/ipsec-ikev2.md) |
| `cisco_anyconnect` | Production | [docs/vpn-solutions/cisco-anyconnect.md](docs/vpn-solutions/cisco-anyconnect.md) |
| `fortinet` | Production (fixture-validated) | [docs/vpn-solutions/fortinet-forticlient.md](docs/vpn-solutions/fortinet-forticlient.md) |
| `globalprotect` | Production (fixture-validated) | [docs/vpn-solutions/palo-alto-globalprotect.md](docs/vpn-solutions/palo-alto-globalprotect.md) |
| `pulse` | Production (CLI + fixtures) | [docs/vpn-solutions/pulse-ivanti.md](docs/vpn-solutions/pulse-ivanti.md) |

## Documentation

- [Architecture](docs/architecture/system-design.md) — all Mermaid diagrams
- [Platform API](docs/architecture/platform-abstraction.md)
- [Scheduling](docs/deploy/scheduling.md) — systemd + LaunchAgent
- [Adapter version matrix](docs/architecture/adapter-version-matrix.md)
- [Plugin guide](docs/architecture/plugin-adapters.md)
- [VPN research (cited)](docs/architecture/research-vpn-platforms.md)
- [Wiki](https://github.com/roto31/Tunnel-Monitor---Universal/wiki)

## CLI capabilities

| Command | Capability |
|---------|------------|
| `check` | Full monitoring cycle |
| `status` | Connection status |
| `statistics` | Probe + adapter metrics |
| `logs` | Recent VPN log lines |
| `diagnostics` | Diagnosis + runbook JSON |
| `explain` | Human-readable runbook |
| `preflight` | Dependency and config checks |
| `adapters` | List registered VPN adapters |

Legacy bash stack: [legacy/README.md](legacy/README.md)
