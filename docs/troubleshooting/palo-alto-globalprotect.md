# Troubleshooting — Palo Alto GlobalProtect

**vpn_type:** `globalprotect`, `gp`  
**Product guide:** [palo-alto-globalprotect.md](../vpn-solutions/palo-alto-globalprotect.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| Neither `gpctl` nor `globalprotect` in PATH | Agent not installed | `UNSUPPORTED` |
| `Not Connected` | No portal session | `VPN_DAEMON_DOWN` |
| `Connected` + LAN fail | Split tunnel / internal host list | `VPN_NEGOTIATION_FAILED` |
| Wrong binary on Linux 6.x | Still calling `gpctl` only | `UNSUPPORTED` or empty parse |
| HIP / MFA pending | Stuck Connecting | `VPN_DAEMON_DOWN` |

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{globalprotect_binary set?}
    B -- no --> C{gpctl exists?}
    C -- no --> D[Install GP 6.x<br/>set globalprotect_binary]
    C -- yes --> E[gpctl show status]
    B -- yes --> F[globalprotect show --status]
    E --> G{Connected?}
    F --> G
    G -- no --> H[globalprotect connect / GUI<br/>VPN_DAEMON_DOWN]
    G -- yes --> I{ping remote_lan_ip?}
    I -- yes --> J[HEALTHY]
    I -- no --> K[VPN_NEGOTIATION_FAILED]
```

---

## CLI selection flow

```mermaid
flowchart TD
    A[Which CLI?] --> B{Linux 6.3+ package}
    B -- yes --> C[globalprotect show --status<br/>globalprotect show --details]
    B -- no --> D[gpctl show status<br/>typical macOS]
    C --> E[globalprotect_binary=/usr/bin/globalprotect]
    D --> F[globalprotect_binary=.../gpctl]
```

---

## VPN_DAEMON_DOWN branch

```mermaid
flowchart TD
    A[Disconnected] --> B[globalprotect show --details<br/>or gpctl show status]
    B --> C{Portal reachable?}
    C -- no --> D[DNS / captive portal / MFA]
    C -- yes --> E[globalprotect connect --gateway FQDN]
    E --> F[Resubmit HIP if required by portal]
    F --> G[uvpn check]
```

```bash
globalprotect show --status
globalprotect show --details
globalprotect show --version
```

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[Connected LAN fail] --> B[show --details<br/>Assigned IP / Gateway]
    B --> C{remote_lan_ip in routed subnet?}
    C -- no --> D[Change probe target to host<br/>in split-tunnel include list]
    C -- yes --> E[Remote firewall ICMP off<br/>still may be HEALTHY if app path works]
    D --> F[uvpn check]
```

Always-on vs on-demand does not change uvpn parsing — only whether session stays up.

---

## Parser failures

```bash
gpctl show status 2>&1 | tee /tmp/gp-status.txt
globalprotect show --status 2>&1 | tee /tmp/gp-status.txt
```

Compare to `tests/fixtures/adapters/globalprotect/`.

---

## Related

- [universal.md](universal.md)
