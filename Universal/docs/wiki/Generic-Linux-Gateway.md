# Generic Linux Gateway

**Path:** `adapters/generic-linux-gateway/`

For any Linux router with systemd and SSH — **no UniFi-specific diagnostics**.

**Install root:** `/opt/tunnel-monitor/`

## Install

```bash
cd adapters/generic-linux-gateway
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env
sudo systemctl start tunnel-monitor.service
tunnel-check --test-email   # if symlinked
```

## Differences from UniFi adapter

| Feature | UniFi | Generic Linux |
|---------|-------|---------------|
| Install path | `/data/tunnel-monitor` | `/opt/tunnel-monitor` |
| Email diagnostics | ipsec + journalctl | reachability summary only |
| WAN Guard | supported | not included |
| OpenVPN recover | supported | not included |

## Requirements

- `bash`, `ping`, `dig`, `curl`, `systemctl`, `logger`
- SMTP submission on port 587

## State API

Gateway writes `/opt/tunnel-monitor/state` as `N:UP` or `N:DOWN` for LAN client dedup over SSH.
