# Configuration

All runtime settings live in **`config.env`** (mode `0600`). Installers copy from `config.env.template` on first run and **never overwrite** an existing file on re-install.

## Topology (all roles)

| Variable | Meaning |
|----------|---------|
| `REMOTE_LAN_IP` | Remote site LAN gateway — pinged **over tunnel** |
| `REMOTE_WAN_IP` | Remote site public IP — pinged over internet |
| `REMOTE_DDNS` | Hostname that should resolve to `REMOTE_WAN_IP` |

## SMTP (all roles)

| Variable | Example |
|----------|---------|
| `SMTP_SERVER` | `smtp.mail.me.com` |
| `SMTP_PORT` | `587` |
| `SMTP_USER` | your email |
| `SMTP_PASSWORD` | app-specific password |
| `ALERT_FROM` | same as SMTP_USER (iCloud) |
| `ALERT_TO` | alert inbox |
| `SUBJECT_PREFIX` | `[MAC]`, `[ROUTER]`, `[LINUX]` |

## Gateway dedup (LAN client only)

| Variable | Default |
|----------|---------|
| `GATEWAY_HOST` | gateway LAN IP |
| `GATEWAY_USER` | `root` |
| `GATEWAY_KEY` | `/opt/tunnel-monitor/.ssh/id_ed25519` |
| `GATEWAY_STATE_PATH` | `/data/tunnel-monitor/state` |

Legacy `ROUTER_*` and `UDR7_*` keys are accepted for entire core 2.x.

## Tuning

| Variable | Default | Notes |
|----------|---------|-------|
| `FAILURE_THRESHOLD` | `3` | × 5 min ≈ 15 min to alert |
| `PING_COUNT` | `3` | per check |
| `PING_TIMEOUT` | `2` | seconds (Linux) / ms scale on macOS |
| `SITE_NAME` | generic | used in email subjects |

## Placeholders

Sanitized templates use `REPLACE_WITH_*` tokens. Full table:

[Public/PLACEHOLDERS.md](https://github.com/roto1231/Tunnel-Monitor---Universal/blob/main/Public/PLACEHOLDERS.md)

## LaunchDaemon label (Mac)

Rename `com.example.tunnel-monitor` in plist filename, `Info.plist`, and wizard before install if you need a unique label.
