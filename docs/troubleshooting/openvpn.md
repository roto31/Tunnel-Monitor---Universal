# Troubleshooting — OpenVPN

**vpn_type:** `openvpn`  
**Product guide:** [openvpn.md](../vpn-solutions/openvpn.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| Management connection refused | `management` not enabled | `UNSUPPORTED` / weak probe |
| State not CONNECTED | Tunnel down | `VPN_DAEMON_DOWN` |
| CONNECTED + LAN fail | Routes / redirect-gateway | `VPN_NEGOTIATION_FAILED` |
| RECONNECTING loop | Link flap | yellow until threshold |
| Process up, no mgmt | Wrong port in config | `UNSUPPORTED` |

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{openvpn_management in config?}
    B -- no --> C[Add management 127.0.0.1 PORT<br/>to .conf or use generic]
    B -- yes --> D{TCP port open?}
    D -- no --> E[Start openvpn<br/>match port]
    D -- yes --> F[nc 127.0.0.1 PORT<br/>state command]
    F --> G{CONNECTED?}
    G -- no --> H[Check certs auth logs<br/>VPN_DAEMON_DOWN]
    G -- yes --> I{ping remote_lan_ip?}
    I -- yes --> J[HEALTHY]
    I -- no --> K[VPN_NEGOTIATION_FAILED]
```

---

## Management interface branch

```mermaid
flowchart TD
    A[Mgmt fails] --> B[grep management openvpn.conf]
    B --> C[systemctl status openvpn@client]
    C --> D{--management-hold?}
    D -- yes --> E[echo hold release | nc ...]
    D -- no --> F[Read greeting + help]
    F --> G[state / status]
```

```bash
nc 127.0.0.1 7505
# or
openvpn_management in config.json → host:port
uvpn preflight
```

---

## VPN_DAEMON_DOWN branch

```mermaid
flowchart TD
    A[Not CONNECTED] --> B[journalctl -u openvpn -n 80]
    B --> C{TLS/auth error?}
    C -- yes --> D[Fix cert/key/ca]
    C -- no --> E[UDP/TCP reachability to server]
    E --> F[Reconnect]
```

Look for `AUTH`, `TLS Error`, `Inactivity timeout`.

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[CONNECTED ping fail] --> B[management status<br/>ROUTING_TABLE]
    B --> C{push redirect-gateway?}
    C -- split --> D[Probe IP inside pushed subnet]
    C -- full --> E[Local firewall blocking tunnel traffic]
```

---

## Without management socket

Use `"vpn_type": "generic"` for ICMP-only, or enable management for production `openvpn` adapter.

---

## Related

- [universal.md](universal.md)
