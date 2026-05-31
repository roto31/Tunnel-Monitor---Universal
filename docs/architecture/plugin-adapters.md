# Plugin adapter development

All VPN-specific logic lives in `src/uvpn/adapters/`. The core engine never branches on vendor names.

## Capability matrix (v1.0)

Incorporated product behavior: [../vpn-solutions/](../vpn-solutions/). No external vendor URLs in operator docs.

| vpn_type | Status | Statistics | Logs | Incorporated guide |
|----------|--------|------------|------|-------------------|
| generic | reachability | probes only | — | — |
| openvpn | mgmt `state` | mgmt `status` | log file | [openvpn.md](../vpn-solutions/openvpn.md) |
| wireguard | `wg show dump` | peer rx/tx | — | [wireguard.md](../vpn-solutions/wireguard.md) |
| ipsec/ikev2 | `swanctl --list-sas` | same | journalctl | [ipsec-ikev2.md](../vpn-solutions/ipsec-ikev2.md) |
| cisco_anyconnect | `vpn state` | `vpn stats` | — | [cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md) |
| fortinet | production CLI parser | version-pinned | — | [fortinet-forticlient.md](../vpn-solutions/fortinet-forticlient.md) |
| globalprotect | `gpctl` parser | version-pinned | — | [palo-alto-globalprotect.md](../vpn-solutions/palo-alto-globalprotect.md) |
| pulse | `pulselauncher status` | CLI contract | — | [pulse-ivanti.md](../vpn-solutions/pulse-ivanti.md) |

## Adding an adapter

1. Subclass `VpnAdapter` in `src/uvpn/adapters/<name>.py`.
2. Implement `probe`, optional `collect_statistics`, `collect_logs`.
3. Add incorporated guide in `docs/vpn-solutions/<name>.md` (sections 1–9 + diagrams).
4. Register in `registry.py`.
5. Add wiki page mirroring section numbers.
6. Add version matrix entry if CLI is version-pinned.
7. Add fixtures under `tests/fixtures/adapters/<name>/`.
