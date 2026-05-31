# Fortinet FortiClient

**vpn_type:** `fortinet` or `forticlient`

## Verified sources

- FortiClient product documentation: https://docs.fortinet.com/product/forticlient
- Supported builds: [adapter-version-matrix.md](../architecture/adapter-version-matrix.md)

## Production status (v1.0.0)

The `fortinet` adapter uses version-pinned CLI parsers (`fortivpn vpn status`, `forticlient vpn status`) validated against vendor-doc fixtures in `tests/fixtures/adapters/fortinet/`.

Unsupported client versions return `supported=False`. Always combine adapter output with universal probes (`remote_lan_ip` ping).

## Config example

```json
{
  "vpn_type": "fortinet",
  "fortinet_binary": "/opt/forticlient/fortivpn",
  "remote_lan_ip": "10.10.0.1",
  "remote_wan_ip": "203.0.113.5"
}
```

## Linux / macOS

Install FortiClient per Fortinet docs, set `fortinet_binary` if not on PATH.

## Monitoring metrics

| Metric | Source | Verified |
|--------|--------|----------|
| Connection state | CLI stdout (version-pinned parser) | Documented-at + fixtures |
| Data plane | ICMP to `remote_lan_ip` | Yes |

## Troubleshooting

- CLI not found → set `fortinet_binary` or use `"vpn_type": "generic"` for reachability-only.
- Connected but LAN down → routing/firewall; diagnosis `TUNNEL_DOWN`.
