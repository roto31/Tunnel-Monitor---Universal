# Tunnel Monitor.app — troubleshooting

[← Hub](Tunnel-Monitor-App)

App-specific issues first; daemon/CLI issues: [[macOS-Monitor]] and [[Tunnel-Monitor-App-Architecture]] alert flow.

---

## App won’t open (error 162 / damaged)

| Cause | Fix |
|-------|-----|
| Unsigned build | Install **release `.pkg`** or adhoc-sign per [[Build-and-Release]] |
| Quarantine | `xattr -cr "/Applications/Tunnel Monitor.app"` then reopen |

---

## Menu bar “not running” / beach ball

Usually fixed in current builds: avoid sheets inside popover; use **Configuration** window. Update to latest [release](https://github.com/roto31/UniFi-Tunnel-Monitor/releases).

If stuck: quit app, `launchctl kickstart -k system/com.example.tunnel-monitor`, reopen.

---

## Setup / Edit Config does nothing or crashes

- **Setup…** needs `AppWindowOpener` on menu label — use current app build.
- **Edit Config** runs Terminal on a background queue — wait a few seconds.

---

## Dot red but router UI shows VPN up

See diagnosis **DISAGREEMENT** in popover — Mac path failed while gateway dedup says UP. Follow [[macOS-Monitor]] runbook for that diagnosis.

---

## No email but banner works

- **Test Email** from popover
- Check `SMTP_*` in [[Tunnel-Monitor-App-Configuration-SMTP]]
- Dedup may suppress email — see gateway SSH section

---

## `state.json` missing or stale

```bash
ls -la /opt/tunnel-monitor/state.json
sudo launchctl print system/com.example.tunnel-monitor
tail -20 /opt/tunnel-monitor/monitor.log
tunnel-check
```

Daemon must be loaded; app only displays what the daemon wrote.

---

## SSH Test fails

Re-run **Copy SSH Auth Cmd**; verify `UDR7_*` keys in [[Tunnel-Monitor-App-Configuration-Gateway-SSH]].

---

## Full diagnosis table

| `diagnosis` | Typical action |
|-------------|----------------|
| `HEALTHY` | None |
| `OUR_INTERNET_DOWN` | Fix Mac WAN |
| `TUNNEL_DOWN` | VPN / firewall on both sites |
| `DDNS_DRIFT` | Update `REMOTE_WAN_IP` or DDNS |
| `REMOTE_INTERNET_DOWN` | Remote site WAN |
| `UDR7_UNREACHABLE` | SSH to gateway; Mac may still alert |
| `DISAGREEMENT` | Compare Mac pings vs gateway monitor |

Details: repo [05-troubleshooting.md](https://github.com/roto31/UniFi-Tunnel-Monitor/blob/main/docs/tunnel-monitor/05-troubleshooting.md).
