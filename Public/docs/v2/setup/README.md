# Setup guides index

Step-by-step configuration for deployments **supported by this repository**.
For category-level guidance on platforms without shipped adapters, see the
category pages — they state limitations explicitly.

## Audience map

| Audience | Start here |
|----------|------------|
| **Operator / end-user** | [Implemented adapters](implemented-adapters.md) → adapter-specific wiki pages |
| **Administrator** | [Configuration](../Configuration) (wiki) + `config.env.template` |
| **Architect** | [Signal flow](signal-flow-and-architecture.md) + [Compatibility](vpn-platform-compatibility.md) |
| **Developer** | [Core contract](../../../vendor/core/CONTRACT.md) + `vendor/core/tests/` |

## Implemented (first-class)

| Guide | VPN / platform | Adapter |
|-------|----------------|---------|
| [Implemented adapters](implemented-adapters.md) | UniFi, generic Linux, macOS/Linux/Windows LAN | Shipped in repo |

## Category guides (no dedicated vendor adapter)

| Guide | Scope |
|-------|--------|
| [Enterprise VPN](enterprise-vpn.md) | Cisco, Fortinet, Palo Alto, similar appliances |
| [Cloud VPN](cloud-vpn.md) | AWS, Azure, GCP site-to-site |
| [Open-source VPN](open-source-vpn.md) | OpenVPN, WireGuard, strongSwan on Linux |

## Prerequisites (all deployments)

1. Site-to-site VPN already configured and routing remote LAN subnets.
2. Stable targets: `REMOTE_LAN_IP`, `REMOTE_WAN_IP`, optional `REMOTE_DDNS`.
3. SMTP app password in `config.env` (never commit secrets).
4. Poll interval ≥ 5 minutes (`CHECK_INTERVAL_MIN=5` default).

## Verify after install

```bash
# LAN client (macOS/Linux with core engine)
/opt/tunnel-monitor/tunnel-check diagnose
/opt/tunnel-monitor/tunnel-check ssh-test
/opt/tunnel-monitor/tunnel-check email-test
```

See adapter `install.sh` and wiki **Troubleshooting** for role-specific checks.
