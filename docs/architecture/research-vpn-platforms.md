# VPN platform research (internal synthesis)

Architecture support for **uvpn**. Monitoring-applicable product behavior is incorporated in reworded form under [../vpn-solutions/](../vpn-solutions/). Each guide ends with a **Citations** table linking authoritative vendor and RFC sources.

---

## Enterprise vs consumer vs self-hosted

| Category | Examples | Typical monitor surface on Linux/macOS |
|----------|----------|----------------------------------------|
| Enterprise SSL/IPsec clients | Cisco Secure Client, FortiClient, GlobalProtect, ISAC | Vendor CLI where installed |
| Enterprise site-to-site | strongSwan, Libreswan | `swanctl`, `ipsec statusall` |
| Consumer / self-hosted | OpenVPN, WireGuard | Management socket; `wg show` |
| Cloud site-to-site | Hyperscaler VPN gateways | No client on host — `generic` probes |

---

## OpenVPN

**Monitoring surface:** TCP management interface (`state`, `status`, `log`).

**Incorporated guide:** [openvpn.md](../vpn-solutions/openvpn.md)

**uvpn adapter:** Management socket from `openvpn_management`; weak fallback without it.

**Limitation:** Management must be enabled in profile.

---

## WireGuard

**Monitoring surface:** `wg show dump` — handshake timestamps and byte counters.

**Incorporated guide:** [wireguard.md](../vpn-solutions/wireguard.md)

**uvpn adapter:** Handshake age heuristic + LAN probe.

**Limitation:** Idle tunnels may show stale handshake despite working path.

---

## IPsec / IKEv2 (strongSwan)

**Monitoring surface:** `swanctl --list-sas` (CHILD SA presence).

**Incorporated guide:** [ipsec-ikev2.md](../vpn-solutions/ipsec-ikev2.md)

**Standards context:** IKEv2 (RFC 7296), IPsec architecture (RFC 4301).

**Limitation:** IKE up ≠ traffic flowing — probes required.

---

## Cisco Secure Client

**Monitoring surface:** `vpn state`, `vpn stats`.

**Incorporated guide:** [cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md)

**Limitation:** Client on endpoint only—not ASA site-to-site appliance monitoring.

---

## Enterprise SSL VPN (v1.0)

| Product | Adapter | Guide | Verification |
|---------|---------|-------|--------------|
| Fortinet FortiClient | `fortinet` | [fortinet-forticlient.md](../vpn-solutions/fortinet-forticlient.md) | Fixtures + documented-at |
| GlobalProtect | `globalprotect` | [palo-alto-globalprotect.md](../vpn-solutions/palo-alto-globalprotect.md) | Fixtures + documented-at |
| Pulse / Ivanti ISAC | `pulse` | [pulse-ivanti.md](../vpn-solutions/pulse-ivanti.md) | Fixtures + [pulse-cli-contract.md](pulse-cli-contract.md) |

Use `generic` only when no vendor client CLI is present.

---

## Standards note

| Protocol | Reference |
|----------|-----------|
| IKEv2 | [RFC 7296](https://www.rfc-editor.org/rfc/rfc7296) |
| IPsec architecture | [RFC 4301](https://www.rfc-editor.org/rfc/rfc4301) |
| WireGuard | [WireGuard protocol](https://www.wireguard.com/protocol/) |

---

## Implementation status (v1.0)

| Product | Status |
|---------|--------|
| Fortinet FortiClient | Production (fixtures) |
| GlobalProtect | Production (fixtures) |
| Pulse / Ivanti | Production (CLI + fixtures) |

See [adapter-version-matrix.md](adapter-version-matrix.md).

---

## Common pain points

1. Control plane vs data plane mismatch (split tunnel, stale SA).
2. ICMP filtering → false `TUNNEL_DOWN`.
3. DDNS drift vs configured WAN IP.
4. No API on appliances — monitor from routed host.

Combined adapter + probe logic: `uvpn/core/diagnosis.py`.

---

## Internal incorporated guides (maintainer index)

| Record | Document |
|--------|----------|
| openvpn-mgmt | [openvpn.md](../vpn-solutions/openvpn.md) |
| wireguard-wg8 | [wireguard.md](../vpn-solutions/wireguard.md) |
| strongswan-swanctl | [ipsec-ikev2.md](../vpn-solutions/ipsec-ikev2.md) |
| cisco-sc5-cli | [cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md) |
| forticlient-74-cli | [fortinet-forticlient.md](../vpn-solutions/fortinet-forticlient.md) |
| globalprotect-6-cli | [palo-alto-globalprotect.md](../vpn-solutions/palo-alto-globalprotect.md) |
| isac-22-cli | [pulse-ivanti.md](../vpn-solutions/pulse-ivanti.md) |

Maintainer provenance manifests (with URLs): `docs/vpn-solutions/manifests/`
