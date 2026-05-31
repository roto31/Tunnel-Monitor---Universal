# Configuration — gateway SSH (dedup)

[← Hub](Tunnel-Monitor-App) · Configuration window

![Gateway SSH dedup](https://raw.githubusercontent.com/roto31/UniFi-Tunnel-Monitor/main/docs/tunnel-monitor/images/setup-ssh-dedup.png)

The Mac reads the **sibling gateway monitor** state file over SSH so it can suppress duplicate emails when the gateway already alerted.

Sanitized builds may show **Router dedup** in the UI; keys are `UDR7_*` or `ROUTER_*` in `config.env`.

---

## Fields

| Key | Label | Default | Notes |
|-----|-------|---------|-------|
| `UDR7_HOST` | Gateway LAN IP (SSH) | `192.168.1.1` | Local UniFi hub |
| `UDR7_USER` | SSH user | `root` | |
| `UDR7_KEY` | SSH private key path | `/opt/tunnel-monitor/.ssh/id_ed25519` | mode `600` |
| `UDR7_STATE_PATH` | Remote state file | `/data/tunnel-monitor/state` | `N:UP` / `N:DOWN` |

---

## One-time SSH setup

From [[Tunnel-Monitor-App-Menu-Bar]]:

1. **Copy SSH Auth Cmd** → paste in Terminal once.
2. **SSH Test** → should pass.

---

## Without a gateway monitor

Leave defaults only if no sibling monitor exists — the Mac will email on every outage (no dedup suppress).

---

## Related

- [[Tunnel-Monitor-App-Configuration-SMTP]]
- [[Tunnel-Monitor-App-Configuration-Topology]]
- [[Tunnel-Monitor-App-Configuration-Tuning]]
- [[UniFi-Gateway-Monitor]]
