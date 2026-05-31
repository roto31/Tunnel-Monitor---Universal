# Troubleshooting — Cisco Secure Client

**vpn_type:** `cisco_anyconnect`  
**Product guide:** [cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| `vpn` not found | Secure Client not installed | `UNSUPPORTED` |
| State disconnected | No profile session | `VPN_DAEMON_DOWN` |
| Connected + LAN fail | Split routing / wrong user context | `VPN_NEGOTIATION_FAILED` |
| GUI connected, CLI disconnected | Wrong OS user / keychain | `VPN_DAEMON_DOWN` |
| Headend down | Remote WAN | `REMOTE_INTERNET_DOWN` |

**Scope:** Endpoint SSL VPN only — not ASA site-to-site on appliance.

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{vpn binary in PATH?}
    B -- no --> C[Install Secure Client<br/>cisco_vpn_binary]
    B -- yes --> D{Same user as GUI session?}
    D -- no --> E[sudo -u USER vpn state<br/>or run uvpn as session owner]
    D -- yes --> F[vpn state]
    F --> G{Connected?}
    G -- no --> H[vpn connect profile<br/>VPN_DAEMON_DOWN]
    G -- yes --> I{ping remote_lan_ip?}
    I -- yes --> J[HEALTHY]
    I -- no --> K[VPN_NEGOTIATION_FAILED]
```

---

## User context flow

```mermaid
flowchart TD
    A[State mismatch] --> B{macOS?}
    B -- yes --> C[Run uvpn as logged-in GUI user<br/>LaunchAgent not root]
    B -- no --> D[Linux: user with active profile]
    C --> E[vpn state && vpn stats]
    D --> E
```

---

## VPN_DAEMON_DOWN branch

```mermaid
flowchart TD
    A[Disconnected] --> B[Open Secure Client GUI<br/>confirm profile]
    B --> C["/opt/cisco/secureclient/bin/vpn connect HOST"]
    C --> D{Interactive MFA?}
    D -- yes --> E[Complete in GUI first<br/>then automate state only]
    D -- no --> F[vpn state]
    F --> G[uvpn check]
```

Windows: `vpncli.exe` from `C:\Program Files (x86)\Cisco\Cisco Secure Client\`.

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[Connected LAN fail] --> B[vpn stats for routes]
    B --> C[Always-on full tunnel?<br/>vs split include]
    C --> D[Adjust remote_lan_ip probe target]
    D --> E[route get REMOTE_LAN_IP]
    E --> F[uvpn check]
```

---

## Logs

Secure Client logs via GUI / DART — not via `vpn state`. uvpn does not collect DART automatically.

---

## Related

- [universal.md](universal.md)
