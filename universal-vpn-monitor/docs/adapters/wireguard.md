# WireGuard adapter

Uses `wg show <interface> dump` per [wg(8)](https://manpages.debian.org/bookworm/wireguard-tools/wg.8.en.html).

```json
{
  "vpn_type": "wireguard",
  "wireguard_interface": "wg0",
  "remote_lan_ip": "10.8.0.1",
  "remote_wan_ip": "203.0.113.5"
}
```

Handshake age &lt; 180s ⇒ connected. Always validate with tunnel ping to `remote_lan_ip`.
