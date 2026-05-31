# Getting Started

You are setting up **insurance**, not homework: a scheduled check that answers whether your VPN client’s story matches the network path you need—before a demo, a deadline, or a Slack ping at 11 p.m.

## Prerequisites

- **Python 3.11+**
- **Linux** or **macOS** (deployment scope)
- `ping` and `dig` in PATH
- VPN client tools for your adapter (see VPN guides)

## Install

```bash
git clone https://github.com/roto31/Tunnel-Monitor---Universal.git
cd Tunnel-Monitor---Universal
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
sudo ln -sf "$(pwd)/scripts/uvpn" /usr/local/bin/uvpn
```

## Configure

```bash
uvpn init-config
${EDITOR:-nano} ~/.config/uvpn/config.json
```

Minimal example (generic — works with any routed P2P VPN):

```json
{
  "vpn_type": "generic",
  "remote_lan_ip": "192.168.10.1",
  "remote_wan_ip": "203.0.113.10",
  "remote_ddns": "remote.example.com"
}
```

Set `vpn_type` to match your stack: `openvpn`, `wireguard`, `ipsec`, `cisco_anyconnect`, `fortinet`, `globalprotect`, `pulse`.

## First run

```bash
uvpn preflight
uvpn check
uvpn status
uvpn explain
uvpn adapters
```

## Periodic monitoring

- Linux: [Scheduling](Scheduling) — systemd timer
- macOS: [Scheduling](Scheduling) — LaunchAgent

## Choose an interface

| Use case | Interface |
|----------|-----------|
| Automation, scripts | [CLI](CLI) |
| SSH, routers, no GUI | [Universal Terminal TUI](Universal-Terminal-TUI) |
| Linux desktop | [Linux GUI](Linux-GUI) |
| macOS menu bar | [macOS GUI](macOS-GUI) |
| Phone/browser on LAN/Tailscale | [Status Portal](Status-Portal) — optional `uvpn-statusd` |

## Optional: status portal (private network)

```bash
pip install -e ".[portal]"
# Token file (chmod 0600), uvpn check, then uvpn-statusd — see Status Portal
```

Security overview: [Security](Security) (NIST CSF / SP 800-53 / SP 800-52).

## Next steps

- Platform guides: [Linux Install](Linux-Install), [macOS Install](macOS-Install)
- Diagrams: [VPN Platform Diagrams](VPN-Platform-Diagrams)
- Enterprise: [Fortinet](Fortinet-FortiClient), [GlobalProtect](Palo-Alto-GlobalProtect), [Pulse](Pulse-Ivanti)
- Open source: [OpenVPN](OpenVPN), [WireGuard](WireGuard), [IPsec IKEv2](IPsec-IKEv2), [Cisco AnyConnect](Cisco-AnyConnect)
