# OpenVPN adapter

Set `"vpn_type": "openvpn"` in `~/.config/uvpn/config.json`.

## Required

- OpenVPN with **management interface** enabled ([docs](https://openvpn.net/community-docs/management-interface.html))
- Default socket: `127.0.0.1:7505`

## Example config

```json
{
  "vpn_type": "openvpn",
  "openvpn_management": "127.0.0.1:7505",
  "remote_lan_ip": "192.168.50.1",
  "remote_wan_ip": "203.0.113.20",
  "remote_ddns": "site.example.com"
}
```

## Verify

```bash
uvpn preflight
uvpn check
uvpn explain
```

## Limits

Without `--management`, adapter falls back to process detection only — use `"vpn_type": "generic"` if management is unavailable.
