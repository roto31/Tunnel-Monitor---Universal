# Getting Started

## Recommended deployment order

1. Establish site-to-site VPN (IPsec or OpenVPN).
2. Install **gateway monitor** on local hub.
3. Install **LAN client** on a Mac (or Linux box) on the same site.
4. Optional: **WAN Guard** if dual-WAN + remote dials your DDNS.
5. Verify with `tunnel-check`.

## Prerequisites

### Both sites

- Remote LAN gateway IP reachable over tunnel (`REMOTE_LAN_IP`).
- Remote public IP or DDNS for drift detection.

### Gateway

- Linux + systemd (UniFi UDM/UDR/UDR7, or generic Linux router).
- SSH root access (UniFi default).
- SMTP on port 587 with app-specific password.

### Mac LAN client

- macOS 12+, `jq` (Homebrew), optional SwiftBar.
- SSH key from Mac → local gateway for dedup.

## Install commands

**UniFi gateway** — copy `adapters/unifi-gateway/` or `Public/unifi/` to the router:

```bash
scp -r adapters/unifi-gateway/ root@GATEWAY_LAN:/root/tunnel-monitor-src
ssh root@GATEWAY_LAN 'cd /root/tunnel-monitor-src && bash install.sh'
nano /data/tunnel-monitor/config.env
tunnel-check --test-email
```

**Mac LAN client:**

```bash
cd Public/mac
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env
tunnel-check --test-email
tunnel-check --ssh-test
```

**Generic Linux gateway:**

```bash
cd adapters/generic-linux-gateway
sudo bash install.sh
```

## Placeholders

Every `REPLACE_WITH_*` value is documented in [Configuration](Configuration) and [`Public/PLACEHOLDERS.md`](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/Public/PLACEHOLDERS.md).

## Next steps

- [Architecture](Architecture) — how dedup works
- [Diagnoses and Alerts](Diagnoses-and-Alerts) — runbook by diagnosis code
- [Tunnel Monitor App](Tunnel-Monitor-App) — menu bar GUI
