# Open-source VPN setup

Transport (IPsec / OpenVPN / WireGuard) is **independent** of monitoring: if `REMOTE_LAN_IP` is routed, ping checks work.

Full guide: [open-source-vpn.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/setup/open-source-vpn.md)

## By transport

| Transport | Gateway path | Extra features |
|-----------|--------------|----------------|
| IPsec on UniFi | [UniFi Gateway](UniFi-Gateway) | `ipsec`/`charon` in alert email |
| IPsec on Linux | [Generic Linux Gateway](Generic-Linux-Gateway) | Ping only (generic hook) |
| OpenVPN on UniFi | UniFi gateway | Optional [openvpn-recover](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/adapters/unifi-gateway/openvpn-recover.sh) |
| OpenVPN on Linux | Generic Linux or LAN client | No auto-recover in repo |
| WireGuard | Generic Linux or LAN client | No `wg` hook shipped |

## Best practices

- `REMOTE_LAN_IP` = remote **LAN** host, not tunnel interface IP.
- OpenVPN recover ≠ HEALTHY — monitor still pings end-to-end.
- Hub dual-WAN + OpenVPN: consider [WAN Guard](WAN-Guard).

## Custom hooks

Operators may add `hooks/diagnostics.sh` under install root (e.g. `wg show`) — not maintained upstream.
