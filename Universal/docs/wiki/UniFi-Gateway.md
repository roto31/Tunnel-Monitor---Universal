# UniFi Gateway

**Paths:** `adapters/unifi-gateway/` (v2 adapter) or `Public/unifi/` (sanitized bundle)

**Install root:** `/data/tunnel-monitor/` (survives UniFi firmware updates)

## Install

```bash
scp -r adapters/unifi-gateway/ root@GATEWAY_LAN:/root/tunnel-monitor-src
ssh root@GATEWAY_LAN
cd /root/tunnel-monitor-src && bash install.sh
nano /data/tunnel-monitor/config.env
tunnel-check --test-email
systemctl start tunnel-monitor.service
```

Re-run `install.sh` after firmware updates if systemd units were wiped.

## What runs

- `monitor.sh` → thin wrapper → `monitor-engine.sh --role gateway`
- Timer: every 5 minutes
- State file: `/data/tunnel-monitor/state` (`N:UP` / `N:DOWN`)
- Alert email includes **ipsec/strongSwan diagnostics** via adapter hook

## Supported hardware

UDM, UDM-Pro, UDM-SE, UDR, UDR7 — any UniFi gateway with Linux + systemd and `/data/` persistence.

## Optional modules

| Module | Path | Default |
|--------|------|---------|
| WAN Guard | `modules/wan-guard/` | manual install |
| OpenVPN recover | `openvpn-recover.sh` | **off** (`RECOVER_ENABLED=0`) |

## CLI

```bash
tunnel-check                  # show state line
tunnel-check --test-email
systemctl list-timers tunnel-monitor.timer
journalctl -u tunnel-monitor.service -n 50
```

See [WAN Guard](WAN-Guard) for dual-WAN DDNS protection.
