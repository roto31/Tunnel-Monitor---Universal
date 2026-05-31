# IPsec / IKEv2 adapter

Uses `swanctl --list-sas` ([strongSwan docs](https://docs.strongswan.org/docs/latest/swanctl/swanctl.html)) or legacy `ipsec statusall`.

```json
{
  "vpn_type": "ipsec",
  "ipsec_tool": "swanctl",
  "remote_lan_ip": "192.168.100.1",
  "remote_wan_ip": "198.51.100.10"
}
```

IKE SA established ≠ traffic flowing — rely on universal probes.
