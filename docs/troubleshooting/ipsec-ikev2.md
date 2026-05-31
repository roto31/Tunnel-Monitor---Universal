# Troubleshooting — IPsec / IKEv2 (strongSwan)

**vpn_type:** `ipsec`, `ikev2`  
**Product guide:** [ipsec-ikev2.md](../vpn-solutions/ipsec-ikev2.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| `swanctl` missing | Package not installed | `UNSUPPORTED` |
| No ESTABLISHED/INSTALLED | SA down | `VPN_DAEMON_DOWN` |
| CHILD up, LAN fail | Selector / routing | `VPN_NEGOTIATION_FAILED` |
| charon not running | Daemon stopped | `VPN_DAEMON_DOWN` |
| Legacy only ipsec.conf | Parser weak | prefer swanctl |

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{swanctl available?}
    B -- no --> C[Install strongSwan swanctl<br/>or ipsec_tool legacy]
    B -- yes --> D[swanctl --list-sas]
    D --> E{ESTABLISHED and INSTALLED?}
    E -- no --> F[swanctl --list-conns<br/>swanctl --load-all<br/>VPN_DAEMON_DOWN]
    E -- yes --> G{ping remote_lan_ip?}
    G -- yes --> H[HEALTHY]
    G -- no --> I[VPN_NEGOTIATION_FAILED]
```

---

## IKE / CHILD branch

```mermaid
flowchart TD
    A[No SA] --> B[journalctl -u strongswan-charon -n 100]
    B --> C{IKE_AUTH fail?}
    C -- yes --> D[PSK/cert mismatch<br/>EAP config]
    C -- no --> E[UDP 500/4500 blocked]
    E --> F[swanctl --initiate --child net-net]
    F --> G[uvpn check]
```

```bash
swanctl --list-sas
swanctl --list-conns
sudo swanctl --load-all
```

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[SA up LAN down] --> B[Verify traffic selectors<br/>local remote subnets]
    B --> C[ip route get REMOTE_LAN_IP]
    C --> D[CHILD_SA matches probe subnet?]
    D --> E[uvpn check]
```

IKE_SA without matching CHILD_SA → uvpn treats as down.

---

## Legacy starter

```mermaid
flowchart TD
    A[Only ipsec statusall] --> B[Set ipsec_tool in config if supported]
    B --> C[Migrate to swanctl conf.d]
    C --> D[Prefer structured list-sas]
```

---

## Related

- [universal.md](universal.md)
