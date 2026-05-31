# Enterprise VPN setup

**No Cisco / Fortinet / Palo Alto adapter ships in this repo.**

Full guide: [enterprise-vpn.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/setup/enterprise-vpn.md)

## Supported patterns

### A — LAN client only (common)

1. Install [Mac](Mac-LAN-Client) or [Linux](Linux-LAN-Client) LAN client.
2. Set `REMOTE_LAN_IP`, `REMOTE_WAN_IP`, `REMOTE_DDNS` in `config.env`.
3. Ensure ICMP to remote LAN is allowed through appliance policy.
4. Run `tunnel-check diagnose`.

**Get:** Full diagnosis enum · **No:** appliance IPsec logs in email, gateway dedup without sidecar

### B — Linux sidecar + generic gateway

1. Install [Generic Linux Gateway](Generic-Linux-Gateway) on a Linux host with routes through the VPN.
2. LAN client SSH-reads `N:UP`/`N:DOWN` for dedup.

**Get:** Same topology as UniFi dual vantage · **No:** vendor-specific diagnostics hook

### C — Not supported

- Native install on ASA / FortiOS / PAN-OS
- API/SNMP tunnel polling (not implemented)

## Troubleshooting

| Diagnosis | Enterprise context |
|-----------|-------------------|
| TUNNEL_DOWN | ACL blocking ICMP or VPN down |
| DISAGREEMENT | Split tunnel / PBR on LAN |
| GATEWAY_UNREACHABLE | No SSH sidecar |

Provide topology details via [Information Gaps](Information-Gaps) for site-specific runbooks.
