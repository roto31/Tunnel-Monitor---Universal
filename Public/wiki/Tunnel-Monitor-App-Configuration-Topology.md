# Configuration — tunnel topology

[← Hub](Tunnel-Monitor-App) · Configuration window

![Tunnel topology](https://raw.githubusercontent.com/roto31/UniFi-Tunnel-Monitor/main/docs/tunnel-monitor/images/setup-topology.png)

These values drive **ping** and **DNS** checks in `monitor.sh` (not the GUI).

---

## Fields

| Key | Label | Notes |
|-----|-------|-------|
| `REMOTE_LAN_IP` | Remote LAN gateway | Pinged **over the VPN tunnel** |
| `REMOTE_WAN_IP` | Remote public IP (expected) | Pinged on the public internet |
| `REMOTE_DDNS` | DDNS hostname | Should resolve to `REMOTE_WAN_IP` when healthy |

---

## Example

```bash
REMOTE_LAN_IP="192.168.0.1"
REMOTE_WAN_IP="203.0.113.50"
REMOTE_DDNS="remote.example.ddns.net"
```

Use [[Placeholders-Reference]] for generic naming.

---

## After No-IP or WAN IP change

1. Update here or via **Edit Config**.
2. **Force Check** in [[Tunnel-Monitor-App-Menu-Bar]].
3. Confirm DNS row is green in popover.

---

## Related

- [[Tunnel-Monitor-App-Configuration-SMTP]]
- [[Tunnel-Monitor-App-Configuration-Gateway-SSH]]
- [[Tunnel-Monitor-App-Configuration-Tuning]]
