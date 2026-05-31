# Linux host hardening — uvpn-statusd

## Users and permissions

```bash
sudo useradd -r -s /usr/sbin/nologin uvpn-status 2>/dev/null || true
sudo usermod -aG uvpn uvpn-status   # read state.json group
sudo chmod 0640 /etc/uvpn/state.json
sudo chgrp uvpn-status /etc/uvpn/state.json
sudo chmod 0600 /etc/uvpn/status-token
sudo chown root:uvpn-status /etc/uvpn/status-token
```

Monitor checks run as root or `uvpn` via timer; portal runs as **`uvpn-status`** (read-only).

## Install

```bash
sudo bash src/deploy/linux/install-statusd.sh
```

## Firewall (SC-7)

Example: [nftables-uvpn-statusd.nft.example](../../src/deploy/statusd/nftables-uvpn-statusd.nft.example)

Allow inbound `tcp/8443` only from Tailscale `100.64.0.0/10` or your management CIDR. Default deny on public interface.

## TLS (SC-8)

Use [Caddyfile.example](../../src/deploy/statusd/Caddyfile.example) on the same host; proxy to `127.0.0.1:8080`.

## Time sync (AU-8)

```bash
timedatectl status
# chrony or systemd-timesyncd active
```

## Verify

```bash
systemd-analyze security uvpn-statusd.service
ss -tlnp | grep 8080
curl -sS -H "Authorization: Bearer $(sudo cat /etc/uvpn/status-token)" https://$(tailscale ip -4):8443/api/v1/status
```
