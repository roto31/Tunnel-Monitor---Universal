# Troubleshooting

## Quick checks

```bash
# Mac / Linux LAN client
tunnel-check
tunnel-check --ssh-test
sudo tunnel-check --check-now
tail -20 /opt/tunnel-monitor/monitor.log

# UniFi gateway
tunnel-check
cat /data/tunnel-monitor/state
journalctl -u tunnel-monitor.service -n 50
```

## Common issues

### No emails

- Verify `SMTP_PASSWORD` is an **app-specific** password
- iCloud: `ALERT_FROM` must equal `SMTP_USER`
- Run `tunnel-check --test-email`
- Check `monitor.log` for curl errors

### SSH dedup always unreachable

- Confirm `GATEWAY_HOST` is gateway **LAN** IP
- Run `tunnel-check --ssh-test`
- Verify Mac/Linux public key in gateway `authorized_keys`
- Check `GATEWAY_STATE_PATH` matches gateway install (`/data/tunnel-monitor/state`)

### SwiftBar / app shows stale data

- Daemon must write `state.json` (check timestamp field)
- App reads only — run `sudo tunnel-check --check-now`
- Verify LaunchDaemon loaded: `sudo launchctl print system/com.example.tunnel-monitor`

### Gateway monitor missing after firmware update

- Re-run `install.sh` on gateway (config preserved)
- `systemctl enable --now tunnel-monitor.timer`

### DISAGREEMENT alerts

- Gateway thinks tunnel UP (`0:UP`) but LAN cannot ping remote LAN IP
- Check Mac/Linux routing, VLAN, split tunnel, local firewall

## Verify scripts

```bash
sudo bash Public/mac/verify.sh      # Mac
sudo bash Public/linux/verify.sh    # Linux
```

## Diagnosis reference

See [Diagnoses and Alerts](Diagnoses-and-Alerts).

Extended runbook: [Public/docs/troubleshooting.md](https://github.com/roto1231/Tunnel-Monitor---Universal/blob/main/Public/docs/troubleshooting.md)
