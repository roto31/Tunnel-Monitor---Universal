# Cloud VPN setup

**No AWS / Azure / GCP API adapter exists.** Monitoring is host-based (ping on a VM or on-prem LAN client).

Full guide: [cloud-vpn.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/setup/cloud-vpn.md)

## Patterns

| Pattern | When |
|---------|------|
| On-prem [LAN client](Mac-LAN-Client) | Hybrid VPN terminates on-prem |
| Linux VM in VPC/VNet | Only cloud subnets reach remote LAN |
| Managed VPN gateway alone | **Insufficient** — no host to run monitor |

## Cloud VM checklist

1. Route table sends remote CIDR via VPN/TGW.
2. Security group/NACL allows ICMP to `REMOTE_LAN_IP`.
3. Install [Linux LAN client](Linux-LAN-Client) or [Generic Linux Gateway](Generic-Linux-Gateway).
4. Verify `ping REMOTE_LAN_IP` before enabling timer.

## Limits

- Cloud console "tunnel UP" ≠ monitor HEALTHY — only ping results matter.
- Lambda-only / API-only monitoring not supported by core engine.

See [Information Gaps](Information-Gaps) for VPC-specific verification.
