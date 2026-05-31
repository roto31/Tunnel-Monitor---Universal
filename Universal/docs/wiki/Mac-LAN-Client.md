# Mac LAN Client

**Path:** `Public/mac/`

**Install root:** `/opt/tunnel-monitor/`

## Install

```bash
cd Public/mac
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env   # set SMTP + topology + GATEWAY_*
tunnel-check --test-email
tunnel-check --ssh-test
sudo tunnel-check --check-now
```

Or install the signed `.pkg` from GitHub Releases (includes app + daemon).

## Components

| Piece | Path / role |
|-------|-------------|
| LaunchDaemon | `/Library/LaunchDaemons/com.example.tunnel-monitor.plist` |
| Engine | `/opt/tunnel-monitor/bin/monitor-engine.sh` |
| Wrapper | `/opt/tunnel-monitor/monitor.sh` |
| Dedup SSH | `ssh-router-state.sh` / `ssh-gateway-state.sh` |
| State | `/opt/tunnel-monitor/state.json` |
| CLI | `/usr/local/bin/tunnel-check` |
| SwiftBar | `~/Library/Application Support/SwiftBar/Plugins/` |

## Config keys (gateway dedup)

Use canonical `GATEWAY_*` keys; legacy `UDR7_*` and `ROUTER_*` still work:

```
GATEWAY_HOST="192.168.1.1"
GATEWAY_USER="root"
GATEWAY_KEY="/opt/tunnel-monitor/.ssh/id_ed25519"
GATEWAY_STATE_PATH="/data/tunnel-monitor/state"
```

## CLI cheat sheet

```bash
tunnel-check                    # pretty status
sudo tunnel-check --check-now   # force run
tunnel-check --test-email
tunnel-check --test-notify
tunnel-check --ssh-test
tunnel-check --tail
```

## GUI

See [Tunnel Monitor App](Tunnel-Monitor-App) for the menu bar application.
