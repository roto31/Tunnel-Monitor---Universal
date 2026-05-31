# Palo Alto GlobalProtect

**vpn_type:** `globalprotect` or `gp`

## Verified sources

- GlobalProtect admin documentation: https://docs.paloaltonetworks.com/globalprotect

## Research gap

`gpctl` is documented for macOS GlobalProtect app management; Linux availability **varies by package**. Adapter uses `gpctl show status` when binary exists.

## Config example

```json
{
  "vpn_type": "globalprotect",
  "globalprotect_binary": "/Applications/GlobalProtect.app/Contents/Resources/gpctl",
  "remote_lan_ip": "172.16.0.1",
  "remote_wan_ip": "198.51.100.20"
}
```

## Monitoring metrics

| Metric | Source | Verified |
|--------|--------|----------|
| Portal connection status | gpctl output (heuristic) | Partial |
| Tunnel reachability | universal probes | Yes |

## Troubleshooting

- gpctl missing on Linux → use `generic` adapter with probes only.
- Split tunnel may show connected while remote LAN fails — expected; diagnosis uses combined adapter + ping.
