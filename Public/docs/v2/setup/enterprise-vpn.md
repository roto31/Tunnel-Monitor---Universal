# Enterprise VPN setup (Cisco, Fortinet, Palo Alto, similar)

**Status:** No enterprise appliance adapter ships in this repository. This page
documents **supported patterns** and **hard limits** based on the actual monitor
design.

---

## What the monitor does (and does not do)

| Does | Does not |
|------|----------|
| ICMP to configured IPs | Poll ASA/FortiOS/PAN-OS APIs |
| DNS compare for DDNS drift | Read VPN tunnel tables via SNMP |
| SSH read of `N:UP`/`N:DOWN` on a **Linux gateway sidecar** | Install on closed appliance OS |

**Source:** `vendor/core/lib/checks.sh`, absence of vendor SDKs in `vendor/core/`.

---

## Compatible deployment patterns

### Pattern A — LAN client only (most common)

Use when the enterprise firewall terminates site-to-site VPN and LAN hosts can
reach `REMOTE_LAN_IP`.

1. Deploy **macOS or Linux LAN client** (`Public/mac/install.sh` or `Public/linux/install.sh`).
2. Set `config.env`:
   - `REMOTE_LAN_IP` = remote site LAN gateway or pingable host
   - `REMOTE_WAN_IP` = remote public IP
   - `REMOTE_DDNS` = if used for drift detection
3. **Omit SSH dedup** or point `GATEWAY_HOST` at a Linux host running Pattern B.
4. Run `tunnel-check diagnose` after VPN is up.

**Capabilities:** Full LAN diagnosis enum except dedup without gateway state.  
**Limitations:** No IPsec log snippet in emails; no gateway-side alerts from the appliance itself.

### Pattern B — Linux sidecar as generic gateway

Use when you can run Linux (VM, small NUC, or router overlay) with routes through the enterprise VPN.

1. Install **`generic-linux-gateway`** on the sidecar.
2. Configure same `REMOTE_*` as the LAN client.
3. Ensure sidecar routing: ping `REMOTE_LAN_IP` succeeds when VPN is up.
4. Enable SSH from LAN client to sidecar; LAN client reads `/opt/tunnel-monitor/state` (or install root).

**Capabilities:** Gateway + LAN dedup, same as UniFi topology.  
**Limitations:** No Cisco/Fortinet/Palo-specific diagnostics hook.

### Pattern C — Not supported

- Running monitor **on** ASA/FortiGate/Palo appliance OS.
- Replacing vendor VPN monitoring with API-based tunnel state.

---

## Configuration requirements

| Variable | Required | Notes |
|----------|----------|-------|
| `REMOTE_LAN_IP` | Yes | Must be routed over site-to-site VPN from monitor host |
| `REMOTE_WAN_IP` | Yes | Used for remote internet vs tunnel-down discrimination |
| `REMOTE_DDNS` | Recommended | Enables `DDNS_DRIFT` diagnosis |
| `GATEWAY_HOST` | If dedup | Linux sidecar only — not the appliance management IP unless it runs the gateway adapter |
| SMTP_* | Yes | For alerts |

---

## Best practices

1. Pick a **stable ping target** on remote LAN (gateway IP, not a DHCP laptop).
2. Allow **ICMP** through enterprise policy (or accept false `TUNNEL_DOWN`).
3. Use **distinct `SUBJECT_PREFIX`** per vantage (`[MAC]`, `[SIDEcar-GW]`).
4. Document whether **asymmetric routing** can cause `DISAGREEMENT` on LAN client.
5. Keep poll interval at **5+ minutes** — do not decrease below 30s (project rule).

---

## Troubleshooting

| Diagnosis | Likely cause on enterprise VPN |
|-----------|--------------------------------|
| `TUNNEL_DOWN` | VPN down, ACL blocking ICMP to remote LAN, or wrong `REMOTE_LAN_IP` |
| `REMOTE_INTERNET_DOWN` | Remote site internet outage; tunnel may still be up |
| `DDNS_DRIFT` | DDNS not updated; static `REMOTE_WAN_IP` mismatch |
| `DISAGREEMENT` | LAN client routing differs from sidecar (policy-based VPN, split tunnel) |
| `GATEWAY_UNREACHABLE` | SSH to sidecar failed — dedup disabled path |

---

## Information needed for site-specific doc

To produce vendor-specific runbooks (e.g. "Cisco ASA + Mac LAN client"), provide:

1. Appliance model/OS and **who terminates** site-to-site (hub/spoke).
2. Whether ICMP is permitted to remote LAN from your Mac/Linux subnet.
3. Whether a Linux sidecar is allowed and its routing table to `REMOTE_LAN_IP`.
4. Sample `show vpn-sessiondb` / equivalent **not required** — we do not ingest it today.

See [INFORMATION-GAPS.md](../INFORMATION-GAPS.md).

---

## Sources

- Repository adapter list: `adapters/*/adapter.manifest.json`
- Generic gateway: `adapters/generic-linux-gateway/`
- Architecture transport note: `Public/docs/architecture.md` §1b
