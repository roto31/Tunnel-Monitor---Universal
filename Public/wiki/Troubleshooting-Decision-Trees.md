# Troubleshooting decision trees

**If [symptom], then [action].** First matching branch wins unless noted.

Companion pages: [[Troubleshooting]] (step-by-step), [[Troubleshooting-Decision-Tree-Diagrams]] (Mermaid for each tree), [[Workflow-Diagrams]], [[Network-Overview]], [[Architecture]].

Configure placeholder values via [[Placeholders-Reference]].

---

## Master triage (start here)

| If | Then |
|----|------|
| You cannot reach **anything** on the internet from the Mac LAN client | Diagnose local ISP first → [OUR_INTERNET_DOWN](#our_internet_down-mac) |
| `tunnel-check` shows **HEALTHY** but a remote device is unreachable | Client/firewall on remote LAN — not a monitor false negative |
| **Both** Mac and gateway emails say tunnel DOWN | Continue → [Tunnel down](#tunnel-down) |
| Only Mac alerts; gateway email suppressed | Expected dedup when gateway state is `N:DOWN` — check Mac banner |
| Primary WAN outage on dual-WAN local hub | → [Dual-WAN / WAN Guard](#dual-wan--wan-guard) |

---

## Tunnel down

### Step 1 — Identify vantage point

| If | Then |
|----|------|
| Mac `tunnel-check` DOWN, SSH to `ROUTER_HOST` **fails** | → [ROUTER_UNREACHABLE](#router_unreachable) |
| Mac DOWN, gateway SSH OK, gateway state **`0:UP`** | → [DISAGREEMENT](#disagreement) |
| Mac DOWN, ping `REMOTE_WAN_IP` **fails** | → [REMOTE_INTERNET_DOWN](#remote_internet_down) |
| Mac DOWN, `dig REMOTE_DDNS` ≠ `REMOTE_WAN_IP` | → [DDNS_DRIFT](#ddns_drift-remote) |
| Mac DOWN, remote WAN OK, DDNS OK | → [OpenVPN / VPN path](#openvpn--vpn-path-down) |

### OpenVPN / VPN path down

| If | Then |
|----|------|
| `dig +short WAN_GUARD_HOSTNAME` returns **private/CGNAT** (`192.168.x`, `10.x`) | Fix DDNS to primary public IP; enable/fix WAN Guard; disable UniFi DDNS on backup WAN |
| Hub DDNS shows last good **public** IP but tunnel still down | Primary WAN may be down — expected until it returns; check `wan-guard status` = `cgnat_blocked` |
| Remote spoke UI **Offline**, local hub SSH ping **`REMOTE_LAN_IP` OK** | Remote-side routing or policy; verify spoke tunnel config |
| Logs show **`Inactivity timeout (--ping-restart)`** | Check default route not stuck on backup WAN; toggle tunnel in UniFi |
| Never connected after config change | Verify 512-char key identical both sides; upstream DMZ/port-forward; try UDP **8443** both ends |
| Still failing | SSH local hub: `journalctl -t openvpn -n 50`; see [[OpenVPN-Site-to-Site-Migration]] |

---

## Dual-WAN / WAN Guard

| If | Then |
|----|------|
| Alert: **CGNAT IP on primary WAN — DDNS blocked** | **Do not** set DDNS to backup WAN address; wait for primary restore |
| `wan-guard status` shows **`cgnat_blocked`** | Normal during primary outage; verify DNS is **not** backup CGNAT |
| Primary restored, status not **`in_sync`** | Run `wan-guard check`; verify `WAN_GUARD_INTERFACE` still correct |
| `wan-guard check` errors **Missing ALERT_EMAIL** | Set `ALERT_TO` in `/data/tunnel-monitor/config.env`; use latest `wan-guard.sh` |
| `wan-guard` CLI cannot find config | Run `/data/wan-guard/wan-guard.sh` directly or redeploy install |

Full runbook: [[WAN-Guard-OpenVPN-Failover]].

---

## DDNS_DRIFT (remote)

**Symptom:** `REMOTE_DDNS` ≠ `REMOTE_WAN_IP`

| If | Then |
|----|------|
| Remote site has internet | Update DDNS A record to current public IP |
| Remote internet down | → [REMOTE_INTERNET_DOWN](#remote_internet_down) |
| Record fixed | Wait one monitor cycle (~5 min) or `sudo tunnel-check --check-now` ×3 |

---

## REMOTE_INTERNET_DOWN

| If | Then |
|----|------|
| Ping `REMOTE_WAN_IP` fails from Mac **and** gateway | Remote ISP outage — no fix on local hub |
| Remote confirms modem up | Check upstream modem; power-cycle |

---

## ROUTER_UNREACHABLE

| If | Then |
|----|------|
| Ping `ROUTER_HOST` from Mac fails | Power/network issue at local gateway |
| Ping OK, `tunnel-check --ssh-test` fails | Fix SSH key in `authorized_keys`; `sudo rm known_hosts` on Mac |
| Repeated after firmware | Re-run Mac `install.sh` SSH setup; re-run gateway `tunnel-monitor` install |

---

## DISAGREEMENT

**Symptom:** Gateway state `0:UP`, Mac cannot ping `REMOTE_LAN_IP`

| If | Then |
|----|------|
| Mac on guest VLAN / wrong network | Rejoin trusted local LAN |
| `route -n get REMOTE_LAN_IP` has no tunnel route | Toggle Mac networking; verify hub routes remote subnet over VPN |
| Mac route OK, still fail | Compare gateway ping from SSH vs Mac; check Mac firewall |

---

## OUR_INTERNET_DOWN (Mac)

| If | Then |
|----|------|
| Ping `1.1.1.1` fails from Mac | Fix local internet; monitor **suppresses** alerts |
| Internet restored, stale DOWN state | `sudo tunnel-check --check-now` until HEALTHY |

---

## Email / alerting

| If | Then |
|----|------|
| No emails, banner works | Check SMTP app password; `tunnel-check --test-email` |
| Duplicate emails Mac + gateway | Dedup broken — verify `tunnel-check --ssh-test` |
| Gateway emails, Mac silent on DOWN | Expected dedup when gateway state is `N:DOWN` |

---

## Post–firmware update (gateway)

| If | Then |
|----|------|
| `tunnel-check` missing or timer inactive | Re-run `tunnel-monitor` `install.sh` |
| `wan-guard` timer inactive | Re-run `wan-guard` `install.sh` |
| Wrong WAN interface on WAN Guard | `ip -4 addr`; update `WAN_GUARD_INTERFACE` |

---

## Legacy IPsec

| If | Then |
|----|------|
| IPsec on network with ISP modem known to block UDP 500/4500 | Migrate to OpenVPN — [[OpenVPN-Site-to-Site-Migration]] |
| `ipsec statusall` empty but OpenVPN up | Safe to disable legacy IPsec tunnels in UniFi UI |

---

## Visual flows

**Decision tree flowcharts (this page as diagrams):** [[Troubleshooting-Decision-Tree-Diagrams]] — master triage, tunnel down, OpenVPN, dual-WAN, DDNS, dedup, email, firmware, IPsec.

**General workflows:** [[Workflow-Diagrams]] — architecture, dual-WAN timeline, install order, operator incident loop.
