# Diagnoses and Alerts

Diagnosis is computed **once per check**; first matching branch wins. See [Core Engine](Core-Engine).

## Diagnosis codes

| Code | Meaning | Email? |
|------|---------|--------|
| `HEALTHY` | Tunnel ping OK | Recovery email if was DOWN |
| `OUR_INTERNET_DOWN` | Local internet down | **No** (counter frozen) |
| `GATEWAY_UNREACHABLE` | Tunnel down, SSH to gateway failed | Yes |
| `DISAGREEMENT` | Gateway says `0:UP`, LAN sees down | Yes |
| `DDNS_DRIFT` | DDNS ≠ expected public IP | Yes (after threshold) |
| `REMOTE_INTERNET_DOWN` | Remote WAN unreachable | Yes |
| `TUNNEL_DOWN` | Tunnel ping fails, else OK | Yes |

Legacy: `UDR7_UNREACHABLE`, `ROUTER_UNREACHABLE` — same intent as `GATEWAY_UNREACHABLE`.

## Alert timing

- Check interval: **5 minutes**
- Default threshold: **3** failures → ~**15 minutes** before first alert
- Recovery: one email + banner when tunnel returns after DOWN state
- Re-alert while DOWN: **suppressed** (no email spam)

## Dedup suppress (LAN client)

When gateway is reachable and state is `N:DOWN`, LAN client **suppresses email** but still shows banner / updates menu bar — unless diagnosis is `GATEWAY_UNREACHABLE` or `DISAGREEMENT`.

## Runbook snippets

| Diagnosis | Action |
|-----------|--------|
| `TUNNEL_DOWN` | SSH gateway; check VPN daemon logs |
| `DDNS_DRIFT` | Update DDNS A record to match `REMOTE_WAN_IP` |
| `REMOTE_INTERNET_DOWN` | Wait / contact remote site |
| `GATEWAY_UNREACHABLE` | Verify gateway power, SSH, firewall |
| `DISAGREEMENT` | Compare LAN routing vs gateway; ping gateway LAN IP |
| `OUR_INTERNET_DOWN` | Fix local internet; no tunnel alert sent |

Full runbook: [Public/docs/troubleshooting.md](https://github.com/roto1231/Tunnel-Monitor---Universal/blob/main/Public/docs/troubleshooting.md)
