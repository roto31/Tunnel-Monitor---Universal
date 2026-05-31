# Cisco AnyConnect / Secure Client

Uses `vpn state` CLI ([Cisco admin guide](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html)).

```json
{
  "vpn_type": "cisco_anyconnect",
  "cisco_vpn_binary": "/opt/cisco/secureclient/bin/vpn",
  "remote_lan_ip": "10.1.0.1",
  "remote_wan_ip": "203.0.113.1"
}
```

**Scope:** SSL VPN **client** on Linux/macOS — not ASA site-to-site on a router. For site-to-site IPsec use `ipsec` adapter on the gateway host or `generic` from LAN.
