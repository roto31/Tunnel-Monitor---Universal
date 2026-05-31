# VPN platform compatibility

Full matrix:
[repo doc](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/vpn-platform-compatibility.md).

**Legend:** **Yes** = shipped adapter · **Partial** = ping works if routed · **No** = not in repo

## Shipped adapters

| Adapter | Role | Path |
|---------|------|------|
| UniFi gateway | gateway | `adapters/unifi-gateway/` |
| Generic Linux gateway | gateway | `adapters/generic-linux-gateway/` |
| macOS / Linux LAN client | lan_client | `Public/mac/`, `Public/linux/` |
| Windows LAN | lan_client | `Public/windows/` (PowerShell, not core engine) |

## Feature matrix (summary)

| Capability | UniFi GW | Generic Linux GW | LAN client | Enterprise appliance | Cloud VPN | OpenVPN/WG Linux |
|------------|----------|------------------|------------|---------------------|-----------|-------------------|
| Ping REMOTE_LAN_IP | Yes | Yes | Yes | Partial | Partial (VM) | Partial |
| Full diagnosis enum | — | — | Yes | Partial | Partial | Partial |
| SSH dedup | — | — | Yes | No* | No* | Partial* |
| IPsec CLI in email | Yes | No | — | No | No | No |
| OpenVPN recover | Optional | No | No | No | No | No |
| WAN Guard | Optional | No | No | No | No | No |
| Vendor VPN API | No | No | No | No | No | No |

\*Unless Linux sidecar runs generic-linux gateway + SSH.

## Categories

| Category | Status | Guide |
|----------|--------|-------|
| UniFi / generic Linux / LAN clients | **First-class** | [Implemented setup](VPN-Setup-Guides) |
| Cisco, Fortinet, Palo Alto | **No adapter** | [Enterprise VPN](Enterprise-VPN-Setup) |
| AWS, Azure, GCP | **No API adapter** | [Cloud VPN](Cloud-VPN-Setup) |
| OpenVPN, WireGuard, strongSwan | **Transport-agnostic ping** | [Open-source VPN](Open-Source-VPN-Setup) |

## Hard limits

- Requires bash, ping, dig, jq (core paths)
- Poll interval ≥ 30s (default 5 min)
- No SNMP / REST VPN polling in core
- Monitor does not configure VPN — operator must establish site-to-site first

## Site-specific verification

See [Information Gaps](Information-Gaps) for the YAML template to promote Partial → Verified for your deployment.
