# Linux troubleshooting

Platform install and GUI notes remain here; **full uvpn runbooks** (per diagnosis + per VPN platform with flowcharts) live in the troubleshooting hub.

## Start here

| Topic | Document |
|-------|----------|
| Universal diagnoses | [troubleshooting/universal.md](../troubleshooting/universal.md) |
| Index + platform flows | [troubleshooting/README.md](../troubleshooting/README.md) |
| Top-level hub | [troubleshooting.md](../troubleshooting.md) |

## Paths

| Item | Location |
|------|----------|
| Config | `~/.config/uvpn/config.json` or `/etc/uvpn/config.json` |
| State | `~/.config/uvpn/state.json` |
| Scheduling | [deploy/scheduling.md](../deploy/scheduling.md) |

## Quick commands

```bash
uvpn preflight
uvpn check
uvpn explain
jq '{diagnosis,traffic_light,failure_count,adapter}' ~/.config/uvpn/state.json
```

## Linux-specific

### GTK GUI unavailable

Install `python3-gi` and `gir1.2-gtk-4.0`, or use `uvpn-tui` — [gui-setup.md](gui-setup.md).

### Ping permissions

Some distributions require `cap_net_raw` on the Python binary or running checks as root for ICMP.

### systemd

```bash
systemctl status uvpn.timer
journalctl -u uvpn.service -n 40
```

See your platform’s guide under [troubleshooting/README.md](../troubleshooting/README.md) for VPN-specific flowcharts.
