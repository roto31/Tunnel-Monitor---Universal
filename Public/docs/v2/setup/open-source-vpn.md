# Open-source / self-hosted VPN setup (OpenVPN, WireGuard, strongSwan)

The monitor treats **VPN transport as independent** of the check layer: if the
host can route to `REMOTE_LAN_IP`, monitoring works the same way.

**Source:** `Public/docs/architecture.md` §1b — "Monitors ping REMOTE_LAN_IP over
whatever VPN UniFi routes — IPsec or OpenVPN."

---

## Transport vs monitoring layer

| Layer | What checks it | Repo support |
|-------|----------------|--------------|
| Tunnel SA / OpenVPN session | Optional gateway hooks, UniFi UI | IPsec hook on UniFi only |
| End-to-end reachability | Core ping probes | All adapters |
| Hub DDNS (OpenVPN dial hostname) | WAN Guard (UniFi hub) | Optional module |

---

## strongSwan / IPsec on UniFi

**First-class path** — use `adapters/unifi-gateway/`.

1. Configure site-to-site IPsec in UniFi Network.
2. Install gateway monitor; IPsec diagnostics appended via `diagnostics-ipsec.sh`:
   - `ipsec statusall` filtered output
   - `journalctl` charon lines
3. LAN client on Mac/Linux for second vantage + dedup.

---

## strongSwan / IPsec on generic Linux

Use `adapters/generic-linux-gateway/`.

- Ping-based detection: **Yes**
- IPsec CLI in email: **No** (generic `diagnostics.sh` summary only)
- To add IPsec snippets: custom `hooks/diagnostics.sh` on install root (operator-maintained)

---

## OpenVPN

### On UniFi (site-to-site or hub-spoke)

1. Standard UniFi gateway + LAN client setup.
2. Optional **`openvpn-recover.sh`** — restarts OpenVPN if down; **separate timer** from tunnel-monitor; does not replace ping logic.

**Source:** `adapters/unifi-gateway/openvpn-recover.sh`, architecture doc.

### On non-UniFi Linux (e.g. OpenVPN on Debian router)

| Option | Role |
|--------|------|
| `generic-linux-gateway` on VPN router | Gateway monitor + state file |
| LAN client on LAN host | Full diagnosis if `REMOTE_LAN_IP` routed through tunnel |

No `openvpn-recover` outside UniFi adapter.

---

## WireGuard

| Feature | Status |
|---------|--------|
| Ping `REMOTE_LAN_IP` over WireGuard | **Partial** — works if routes installed |
| WireGuard-specific hook | **No** |
| `wg show` in alert email | **No** (not implemented) |

**Setup:** Treat as generic routed VPN — deploy LAN client or generic-linux gateway; configure `REMOTE_*` only.

Custom hook example (operator-owned, not shipped):

```bash
# /opt/tunnel-monitor/hooks/diagnostics.sh — optional
wg show 2>/dev/null | head -20
```

---

## Feature matrix (open-source transports)

| Transport | Gateway adapter | LAN client | VPN CLI in email | Auto-recover module |
|-----------|-----------------|------------|------------------|---------------------|
| IPsec on UniFi | unifi-gateway | Yes | ipsec/charon | No (IPsec) |
| IPsec on Linux | generic-linux | Yes | No (default) | No |
| OpenVPN on UniFi | unifi-gateway | Yes | No | openvpn-recover (optional) |
| OpenVPN on Linux | generic-linux | Yes | No | No |
| WireGuard | generic-linux or LAN only | Yes | No | No |

---

## Configuration best practices

1. Choose `REMOTE_LAN_IP` on the **remote LAN subnet**, not the tunnel interface IP.
2. For OpenVPN hub DDNS, align `REMOTE_DDNS` with the hostname spokes dial; use **WAN Guard** on hub if dual-WAN can desync DDNS.
3. Do not conflate **OpenVPN recover "UP"** with **HEALTHY** — recover only restarts daemon; monitor still pings `REMOTE_LAN_IP`.

---

## Troubleshooting

| Symptom | OpenVPN / WireGuard angle |
|---------|---------------------------|
| `TUNNEL_DOWN` but `wg show` / `openvpn` looks up | Routing or firewall; ping path ≠ daemon status |
| `DDNS_DRIFT` | Common on dynamic hub WAN; fix DDNS or use WAN Guard |
| Recover runs but alerts continue | Remote LAN still unreachable — fix peer/routes |

---

## Sources

- `Public/docs/architecture.md` §1b
- `adapters/unifi-gateway/hooks/diagnostics-ipsec.sh`
- `adapters/unifi-gateway/openvpn-recover.sh`
- `adapters/generic-linux-gateway/hooks/diagnostics.sh`
