# Troubleshooting (uvpn)

Complete runbooks for the **Universal VPN Monitor** build, modeled after [legacy/Public/docs/troubleshooting.md](legacy/Public/docs/troubleshooting.md).

**Start here:** [troubleshooting/README.md](troubleshooting/README.md)

| Document | Description |
|----------|-------------|
| [Universal diagnoses + master flow](troubleshooting/universal.md) | All uvpn codes, alert timing, decision tree |
| [OpenVPN](troubleshooting/openvpn.md) | Management socket workflows |
| [WireGuard](troubleshooting/wireguard.md) | Handshake + routing flows |
| [IPsec / IKEv2](troubleshooting/ipsec-ikev2.md) | strongSwan SA workflows |
| [Cisco Secure Client](troubleshooting/cisco-anyconnect.md) | `vpn state` / user context |
| [FortiClient](troubleshooting/fortinet-forticlient.md) | Linux + Windows CLI flows |
| [GlobalProtect](troubleshooting/palo-alto-globalprotect.md) | gpctl vs globalprotect |
| [Pulse / Ivanti](troubleshooting/pulse-ivanti.md) | pulselauncher + Trusted Server |
| [Generic](troubleshooting/generic.md) | ICMP-only monitoring |

## First steps

```bash
uvpn preflight
uvpn check
uvpn explain
```

## Legacy UniFi tunnel-monitor

Site-specific bash monitor (gateway SSH dedup, WAN Guard, OpenVPN site-to-site): [legacy/Public/docs/troubleshooting.md](legacy/Public/docs/troubleshooting.md).
