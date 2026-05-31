# Fortinet FortiClient

**vpn_type:** `fortinet` or `forticlient`

## Verified sources

- FortiClient product documentation: https://docs.fortinet.com/product/forticlient

## Research gap

FortiClient CLI subcommands (`fortivpn`, `forticlient vpn status`) **vary by OS and version**. The uvpn adapter uses **heuristic parsing** — validate output on your deployment before relying on control-plane status alone.

Always combine with universal probes (`remote_lan_ip` ping).

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
| Connected heuristic | CLI stdout | Partial — version-dependent |
| Data plane | ICMP to `remote_lan_ip` | Yes |

## Troubleshooting

- CLI not found → set `fortinet_binary` or use `"vpn_type": "generic"`.
- Connected but LAN down → routing/firewall; trust diagnosis `TUNNEL_DOWN`.
