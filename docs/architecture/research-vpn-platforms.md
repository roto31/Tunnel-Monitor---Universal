# VPN platform research (verified sources)

This document supports architecture decisions for **uvpn**. Claims are tied to primary sources. Where the vendor exposes **no stable monitoring API on Linux/macOS clients**, uvpn uses **documented CLIs** or falls back to **generic reachability**.

---

## Enterprise vs consumer vs self-hosted

| Category | Examples | Typical monitor surface on Linux/macOS |
|----------|----------|----------------------------------------|
| Enterprise SSL/IPsec clients | Cisco Secure Client, FortiClient, GlobalProtect | Vendor CLI where installed; often opaque |
| Enterprise site-to-site | strongSwan, Libreswan, router IPsec | `swanctl`, `ipsec statusall` |
| Consumer / self-hosted | OpenVPN, WireGuard | OpenVPN management interface; `wg show` |
| Cloud site-to-site | AWS/Azure/GCP VPN gateways | **No client on host** — monitor from VM using generic probes only |

---

## OpenVPN

**Monitoring API:** TCP/Unix **management interface** documented in OpenVPN community docs.

| Capability | Supported | Source |
|------------|-----------|--------|
| Real-time state | `state` command | [Management Interface](https://openvpn.net/community-docs/management-interface.html) |
| Status dump | `status` command | [management-notes.txt](https://github.com/OpenVPN/openvpn/blob/master/doc/management-notes.txt) |
| Log stream | `log on` | Same |

**uvpn adapter:** probes management socket (`openvpn_management` in config); fallback process/status file.

**Limitation:** Management socket must be enabled in server/client config (`--management`). Without it, only generic ping applies.

---

## WireGuard

**Monitoring API:** userspace `wg` utility — not a network API.

| Capability | Supported | Source |
|------------|-----------|--------|
| Peer list | `wg show` | [wg(8) Debian man page](https://manpages.debian.org/bookworm/wireguard-tools/wg.8.en.html) |
| Handshake age | `latest-handshakes` / dump TSV | Same |
| Machine parse | `wg show dump` | Same |

**uvpn adapter:** parses `wg show <iface> dump`; treats recent handshake (&lt;180s) as connected.

**Limitation:** Site-to-site WireGuard may not update handshake if no traffic — combine with tunnel ping probe.

---

## IPsec / IKEv2 (strongSwan)

**Monitoring API:** `swanctl` over **VICI** socket.

| Capability | Supported | Source |
|------------|-----------|--------|
| List IKE/CHILD SAs | `swanctl --list-sas` | [swanctl tool](https://docs.strongswan.org/docs/latest/swanctl/swanctl.html) |
| Human vs machine output | `--raw` for debugging; VICI for automation | [GitHub issue #493](https://github.com/strongswan/strongswan/issues/493) |

**uvpn adapter:** `swanctl --list-sas` grep for `ESTABLISHED` and `INSTALLED`; fallback `ipsec statusall` (legacy starter/ipsec).

**Limitation:** IKE SA up does not guarantee traffic flow — universal ping to `remote_lan_ip` remains required ([strongSwan monitoring guidance](https://docs.strongswan.org/docs/latest/swanctl/swanctlListSas.html)).

---

## Cisco AnyConnect / Secure Client

**Monitoring API:** **`vpn` CLI** — `state`, `stats`, `connect`, `disconnect`.

| Capability | Supported | Source |
|------------|-----------|--------|
| Connection state | `vpn state` | [Cisco Secure Client 5 admin guide — CLI](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html) |
| Binary path Linux/macOS | `/opt/cisco/secureclient/bin/vpn` | Same |

**uvpn adapter:** runs `vpn state`; parses Connected/Disconnected.

**Limitations (verified):**
- Requires proprietary client installed — not available on headless Linux servers without client package.
- **Site-to-site IPsec on ASA** is not the same as AnyConnect SSL VPN client — do not use this adapter for router-based IPsec; use `ipsec` adapter on the gateway or `generic` from LAN.

---

## Enterprise SSL VPN clients (v1.0 status)

| Product | Adapter | Monitoring surface | Verification |
|---------|---------|-------------------|--------------|
| Fortinet FortiClient | `fortinet` | `fortivpn vpn status` (version-pinned) | [FortiClient docs](https://docs.fortinet.com/product/forticlient) + [version matrix](adapter-version-matrix.md) — **documented-at, fixture-validated** |
| Palo Alto GlobalProtect | `globalprotect` | `gpctl show status` | [GlobalProtect docs](https://docs.paloaltonetworks.com/globalprotect) + fixtures — **documented-at** |
| Pulse / Ivanti | `pulse` | `pulselauncher status` | [Ivanti Product Help](https://help.ivanti.com/ps/) + fixtures — **documented-at** |

Use `generic` only when no vendor client is installed.

---

## Consumer and self-hosted VPN

| Solution | Typical deployment | uvpn adapter |
|----------|-------------------|--------------|
| OpenVPN (self-hosted) | Linux/macOS client or gateway | `openvpn` |
| WireGuard (self-hosted) | `wg-quick`, router, cloud VM | `wireguard` |
| Tailscale / Mesh | Userspace WireGuard derivative | `wireguard` or `generic` — **Tailscale has separate API; not bundled** |
| Commercial consumer VPN | Often opaque client | `generic` probes only |

**Assumption (not verified as universal):** Consumer VPN apps rarely expose stable local CLIs — uvpn defaults to reachability probes.

---

## Standards note (WireGuard / IKEv2)

| Protocol | Correct reference |
|----------|-------------------|
| IKEv2 | [RFC 7296](https://www.rfc-editor.org/rfc/rfc7296) |
| IPsec architecture | [RFC 4301](https://www.rfc-editor.org/rfc/rfc4301) |
| WireGuard protocol | [wireguard.com/protocol](https://www.wireguard.com/protocol/) — **not** RFC 7539 (that defines ChaCha20-Poly1305) |

---

## Protocols — implementation status (v1.0)

| Product | Status | Notes |
|---------|--------|-------|
| Fortinet FortiClient | **Production (fixtures)** | Unsupported versions → `supported=False` |
| Palo Alto GlobalProtect | **Production (fixtures)** | Separate macOS/Linux fixture sets |
| Pulse Secure / Ivanti | **Production (CLI + fixtures)** | Use `pulse`, not `generic`, when client installed |

Validation is vendor-doc fixture based (no lab). See [adapter-version-matrix.md](adapter-version-matrix.md).

---

## Common pain points (cross-platform)

1. **Control plane vs data plane mismatch** — VPN “connected” but remote LAN unreachable (policy routing, split tunnel, stale SA).
2. **ICMP filtering** — false `TUNNEL_DOWN` if firewalls block ping but apps work.
3. **DDNS drift** — remote public IP changed; peers dial wrong address.
4. **No API on appliances** — monitoring must run on a host with routing into the tunnel.

uvpn addresses (1)–(3) via combined adapter + probe diagnosis tree in `uvpn/core/diagnosis.py`.

---

## References

1. OpenVPN Management Interface — https://openvpn.net/community-docs/management-interface.html  
2. OpenVPN management-notes.txt — https://github.com/OpenVPN/openvpn/blob/master/doc/management-notes.txt  
3. WireGuard wg(8) — https://manpages.debian.org/bookworm/wireguard-tools/wg.8.en.html  
4. strongSwan swanctl — https://docs.strongswan.org/docs/latest/swanctl/swanctl.html  
5. strongSwan VICI note — https://github.com/strongswan/strongswan/issues/493  
6. Cisco Secure Client CLI — https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html  
