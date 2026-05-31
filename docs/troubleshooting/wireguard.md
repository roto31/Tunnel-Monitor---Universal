# Troubleshooting — WireGuard

**vpn_type:** `wireguard`  
**Product guide:** [wireguard.md](../vpn-solutions/wireguard.md)

---

## Quick symptom table

| Symptom | Likely cause | uvpn diagnosis |
|---------|--------------|----------------|
| `wg` not found | wireguard-tools missing | `UNSUPPORTED` |
| Interface missing | wg0 down | `VPN_DAEMON_DOWN` |
| Stale handshake | Peer idle / UDP blocked | `VPN_DAEMON_DOWN` |
| Fresh handshake, LAN fail | AllowedIPs / routing | `VPN_NEGOTIATION_FAILED` |
| Handshake 0 | Never established | `TUNNEL_DOWN` |

---

## Master troubleshooting flow

```mermaid
flowchart TD
    A[uvpn not HEALTHY] --> B{wg in PATH?}
    B -- no --> C[Install wireguard-tools]
    B -- yes --> D{wg show IFACE exists?}
    D -- no --> E[wg-quick up IFACE<br/>VPN_DAEMON_DOWN]
    D -- yes --> F[wg show IFACE dump]
    F --> G{handshake age under 180s?}
    G -- no --> H[Check endpoint keys UDP 51820<br/>VPN_DAEMON_DOWN]
    G -- yes --> I{ping remote_lan_ip?}
    I -- yes --> J[HEALTHY]
    I -- no --> K[VPN_NEGOTIATION_FAILED]
```

---

## Handshake branch

```mermaid
flowchart TD
    A[Stale or zero handshake] --> B[wg show wg0 dump]
    B --> C{endpoint reachable?}
    C -- no --> D[Firewall NAT UDP<br/>wrong Endpoint= IP]
    C -- yes --> E[Peer PublicKey mismatch]
    E --> F[wg-quick down/up]
    F --> G[uvpn check]
```

```bash
wg show wg0
wg show wg0 dump
sudo wg-quick up wg0
```

---

## VPN_NEGOTIATION_FAILED branch

```mermaid
flowchart TD
    A[Handshake OK LAN fail] --> B[Check AllowedIPs includes<br/>remote_lan_ip subnet]
    B --> C[ip route get REMOTE_LAN_IP]
    C --> D[PostUp rules in wg-quick conf]
    D --> E[uvpn check]
```

Handshake fresh + LAN fail is common with **too-narrow AllowedIPs**.

---

## Permissions

`wg` often requires root — run `uvpn check` with privileges that can read interface state.

---

## Related

- [universal.md](universal.md)
