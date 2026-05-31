# Information gaps — required for site-specific accuracy

The diagrams and compatibility charts in `Public/docs/v2/` are **accurate for the
code in this repository**. Several deliverables cannot be completed as
vendor-specific facts without input from you.

---

## Already verified from the codebase

| Topic | Location |
|-------|----------|
| Signal flow and diagnosis order | `vendor/core/lib/diagnosis.sh`, `monitor-engine.sh` |
| Health probes | `vendor/core/lib/checks.sh` |
| Shipped adapters | `adapters/*/adapter.manifest.json` |
| State contracts | `vendor/core/CONTRACT.md` |
| Transport vs monitoring | `Public/docs/architecture.md` |
| Windows separate stack | `Public/windows/payload/monitor.ps1` |

---

## Details needed from you

### 1. Production topology

| Field | Why we need it |
|-------|----------------|
| Hub vs spoke site names | Diagram labels and `SITE_NAME` examples |
| Which side runs gateway vs LAN client | Dedup and alert routing |
| VPN vendor/model on each side | Compatibility row promotion Partial → Yes |
| IPsec vs OpenVPN vs WireGuard per link | Hook and module applicability |

### 2. Reachability proof

| Field | Why we need it |
|-------|----------------|
| `REMOTE_LAN_IP` candidate and ping result from each vantage | Confirms Pattern A/B/C |
| Whether ICMP is filtered by enterprise/cloud policy | Avoid false `TUNNEL_DOWN` docs |
| Asymmetric routing known issues | Explains `DISAGREEMENT` runbooks |

### 3. Dedup and SSH

| Field | Why we need it |
|-------|----------------|
| Will a Linux gateway sidecar run `generic-linux-gateway`? | Enables dedup matrix Yes |
| SSH user/host for gateway state read | LAN `config.env` template |
| Firewall rules LAN → gateway:22 | `GATEWAY_UNREACHABLE` troubleshooting |

### 4. Optional modules

| Field | Why we need it |
|-------|----------------|
| UniFi hub dual-WAN? | WAN Guard applicability |
| OpenVPN on UniFi hub? | openvpn-recover applicability |
| DDNS provider and hostname | WAN Guard + `DDNS_DRIFT` docs |

### 5. Enterprise / cloud scope intent

| Question | Options |
|----------|---------|
| Is **LAN-client-only** acceptable for Cisco/Fortinet/Palo? | Yes / must have gateway on appliance |
| Should we **build a new adapter** (e.g. SNMP/API)? | Out of current scope unless requested |
| Cloud: monitor on-prem, in VPC, or both? | Affects setup guide emphasis |

### 6. Windows deployment

| Field | Why we need it |
|-------|----------------|
| Will Windows LAN client stay on PowerShell or migrate to WSL/core? | Roadmap for parity with v2 engine |
| Need desktop notifications on Windows? | Currently stub only |

---

## What we will not document without evidence

- Vendor API field mappings (Cisco/Fortinet/Palo/AWS/Azure/GCP).
- Guaranteed compatibility with a specific appliance firmware version.
- ICMP-through-VPN success for your ACL policy (operator must verify).
- SNMP trap integration (not in repo).

---

## Template — fill and return

```yaml
site_name: ""
local_gateway_platform: ""   # e.g. UniFi UDM Pro, FortiGate 60F, none
remote_gateway_platform: ""
vpn_transport: ""              # ipsec | openvpn | wireguard | mixed
remote_lan_ip: ""
remote_wan_ip: ""
remote_ddns: ""
lan_client_os: []              # macos | linux | windows
gateway_monitor: ""            # unifi | generic-linux | none
ssh_dedup_host: ""
dual_wan_hub: false
openvpn_recover_desired: false
icmp_allowed_to_remote_lan: unknown   # yes | no | unknown
```

With this, wiki pages can be updated from **Partial** to **Verified** for your deployment.

---

## Suggested next documentation actions

1. Add filled template to private ops repo (not committed secrets).
2. Promote your site to a **Verified deployment** subsection on wiki Home.
3. If building enterprise adapter: new issue defining hook contract (API vs SSH vs SNMP).
