# Product definition

**Universal VPN Monitor (uvpn)** lives at the **repository root**.

It monitors any point-to-point VPN where a host can:

1. Run **protocol adapters** (OpenVPN, WireGuard, IPsec, Cisco AnyConnect, …), and  
2. Run **universal reachability probes** (ICMP, DDNS) independent of vendor.

## Interfaces

| Interface | Path |
|-----------|------|
| CLI | `uvpn` / `scripts/uvpn` |
| Universal terminal | `scripts/uvpn-tui` |
| Linux GUI | `apps/linux/uvpn_gui.py` |
| macOS GUI | `apps/macos/UniversalVPNMonitor/` |

## Legacy

The bash UniFi/site-specific stack is under [`legacy/`](legacy/README.md).

Previous GitHub "Universal" naming referred to that bash fork — **incorrect** for platform-agnostic goals.

## Start here

[README.md](README.md)
