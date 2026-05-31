# Universal VPN Monitor — product definition

The **Universal** product is **`universal-vpn-monitor/`** (Python core **uvpn**).

It monitors **any point-to-point VPN** where a host can:

1. Run protocol-specific checks via **adapters** (OpenVPN, WireGuard, IPsec, Cisco AnyConnect, …), and  
2. Run **universal reachability probes** (ping remote LAN, remote WAN, DDNS) independent of vendor.

## What Universal is NOT

| Path | Status |
|------|--------|
| `Public/` + bash `vendor/core/` | **Legacy** UniFi/site-specific monitor — kept for backward compatibility |
| Previous “Universal” GitHub fork | Was a **rename** of the bash stack — **incorrect** product definition |

## Interfaces (equivalent capabilities)

- **CLI:** `uvpn` (Python)
- **Universal terminal:** `uvpn-tui` (shell menu)
- **Linux GUI:** GTK4 (`apps/linux/uvpn_gui.py`)
- **macOS GUI:** Swift (`apps/macos/UniversalVPNMonitor/`)

## Start here

[universal-vpn-monitor/README.md](universal-vpn-monitor/README.md)

## Architecture

[universal-vpn-monitor/docs/architecture.md](universal-vpn-monitor/docs/architecture.md)
