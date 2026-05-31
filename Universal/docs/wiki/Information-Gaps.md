# Information gaps

Repo docs are **code-accurate**. Site-specific vendor runbooks need your input.

Full list: [INFORMATION-GAPS.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/docs/v2/INFORMATION-GAPS.md)

## Template (fill for your site)

```yaml
site_name: ""
local_gateway_platform: ""
remote_gateway_platform: ""
vpn_transport: ""              # ipsec | openvpn | wireguard | mixed
remote_lan_ip: ""
remote_wan_ip: ""
remote_ddns: ""
lan_client_os: []              # macos | linux | windows
gateway_monitor: ""            # unifi | generic-linux | none
ssh_dedup_host: ""
dual_wan_hub: false
openvpn_recover_desired: false
icmp_allowed_to_remote_lan: unknown
```

## What we need most

1. **Topology** — hub/spoke, which side runs gateway vs LAN client
2. **Reachability** — ping `REMOTE_LAN_IP` from each vantage (yes/no)
3. **Dedup** — Linux sidecar for SSH state read?
4. **Scope** — LAN-only OK for enterprise, or require appliance integration?

## We will not document without evidence

- Vendor API field mappings
- Guaranteed ICMP through your ACL policy
- SNMP integration (not in repository)

Return a filled template to upgrade [Compatibility](VPN-Platform-Compatibility) from Partial to Verified for your deployment.
