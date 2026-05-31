# Palo Alto GlobalProtect

**vpn_type:** `globalprotect` or `gp`

## Verified sources

- GlobalProtect admin documentation: https://docs.paloaltonetworks.com/globalprotect
- Supported builds: [adapter-version-matrix.md](../architecture/adapter-version-matrix.md)

## Production status (v1.0.0)

The `globalprotect` adapter parses `gpctl show status` output using vendor-doc fixtures (`tests/fixtures/adapters/globalprotect/`). Separate macOS and Linux fixture sets.

When `gpctl` is missing, adapter returns `supported=False` — use `generic` for reachability-only monitoring.

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
| Portal connection status | `gpctl show status` parser | Documented-at + fixtures |
| Tunnel reachability | universal probes | Yes |

## Troubleshooting

- gpctl missing on Linux → set `globalprotect_binary` or use `generic` with probes only.
- Split tunnel may show connected while remote LAN fails — diagnosis uses combined adapter + ping.
