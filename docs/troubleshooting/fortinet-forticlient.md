# Troubleshooting — FortiClient

**vpn_type:** `fortinet`, `forticlient`  
**Product guide:** [fortinet-forticlient.md](../vpn-solutions/fortinet-forticlient.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| `forticlient` / `FortiVPN` missing | Not installed | `UNSUPPORTED` |
| `VPN Status: Disconnected` | No tunnel | `VPN_DAEMON_DOWN` |
| `Connecting` stuck | Auth / gateway | `VPN_DAEMON_DOWN` |
| Connected + LAN fail | Split tunnel EMS policy | `VPN_NEGOTIATION_FAILED` |
| Empty status | No profile / wrong version | `UNSUPPORTED` |
| Ubuntu SSL VPN 0 bytes | Known 7.x issue — see Fortinet release notes | probe may fail |

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{preflight: CLI found?}
    B -- no --> C[Install FortiClient 7.x<br/>set fortinet_binary]
    B -- yes --> D{Linux or Windows CLI?}
    D --> L[forticlient vpn status]
    D --> W[FortiVPN --cli --status]
    L --> E{Connected in output?}
    W --> E
    E -- no --> F[forticlient vpn list<br/>connect profile<br/>VPN_DAEMON_DOWN]
    E -- yes --> G{ping remote_lan_ip?}
    G -- yes --> H[HEALTHY]
    G -- no --> I[VPN_NEGOTIATION_FAILED<br/>or DDNS / REMOTE_WAN per universal]
```

---

## VPN_DAEMON_DOWN branch

```mermaid
flowchart TD
    A[VPN_DAEMON_DOWN] --> B{Profile exists?}
    B -- no --> C[EMS push or forticlient vpn edit<br/>GUI create profile]
    B -- yes --> D[forticlient vpn connect PROFILE<br/>or GUI connect]
    D --> E{status Connected?}
    E -- no --> F[Linux: gnome-keyring for SAML SSL<br/>Windows: FortiVPN --cli --status per tunnel]
    E -- yes --> G[uvpn check]
```

### Commands

```bash
forticlient vpn list
forticlient vpn status
forticlient vpn connect corporate-vpn
# Windows
"/c/Program Files/Fortinet/FortiClient/FortiVPN.exe" --cli --status
uvpn preflight
```

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[Status Connected LAN down] --> B[forticlient vpn status<br/>confirm profile name]
    B --> C[Check EMS split tunnel routes]
    C --> D[ping remote_lan_ip inside allowed subnet]
    D --> E[ip route / policy route on endpoint]
    E --> F[uvpn check]
```

EMS may push **split tunnel** — `remote_lan_ip` must be an address reachable when tunnel is “up”.

---

## Parser / version issues

```mermaid
flowchart TD
    A[supported=False or UNKNOWN] --> B[Capture full status stdout]
    B --> C{Matches 7.4.x fixtures?}
    C -- no --> D[Pin client version<br/>adapter-version-matrix]
    C -- yes --> E[File issue with redacted stdout]
```

Fixtures: `tests/fixtures/adapters/fortinet/`.

---

## Logs

| Source | Command |
|--------|---------|
| Linux GUI | FortiClient diagnostic bundle |
| EMS | Centralized logging if enrolled |
| uvpn | `jq '.adapter' ~/.config/uvpn/state.json` |

FortiESNAC `--details` is **EMS registration**, not VPN status — do not use for tunnel diagnosis.

---

## Related

- [universal.md](universal.md)  
- [adapter-version-matrix.md](../architecture/adapter-version-matrix.md)
