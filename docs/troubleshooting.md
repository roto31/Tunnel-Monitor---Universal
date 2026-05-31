# Troubleshooting

## Config and paths

| Item | Location |
|------|----------|
| Config | `~/.config/uvpn/config.json` |
| State | `~/.config/uvpn/state.json` |
| Logs | stderr from `uvpn check`; no daemon log file by default |

Run `uvpn preflight` before first check — validates JSON, required fields, and tool availability.

## Common diagnoses

| Diagnosis | Meaning | First steps |
|-----------|---------|-------------|
| `HEALTHY` | Tunnel and probes OK | None |
| `TUNNEL_DOWN` | Remote LAN unreachable | Check VPN daemon, routing, firewall |
| `REMOTE_INTERNET_DOWN` | LAN OK, remote WAN fail | Remote site ISP or gateway issue |
| `OUR_INTERNET_DOWN` | Cannot reach 1.1.1.1 | Local ISP or default route |
| `DDNS_DRIFT` | DDNS resolves ≠ configured WAN | Update `remote_wan_ip` or fix DDNS |
| `VPN_DAEMON_DOWN` | Adapter reports daemon stopped | Restart OpenVPN/WireGuard/strongSwan/Cisco client |
| `VPN_NEGOTIATION_FAILED` | Session not established | Check credentials, phase1/2, peer reachability |
| `UNSUPPORTED_VPN_TYPE` | Unknown `vpn_type` | Use `generic` or add adapter |

Run `uvpn explain` for runbook steps matching the last diagnosis.

## Adapter-specific

### OpenVPN

- Enable management interface: `management localhost 7505` in server/client config.
- Set `openvpn_management_host` / `openvpn_management_port` in config.

See [adapters/openvpn.md](adapters/openvpn.md).

### WireGuard

- Requires `wg` in PATH and correct `wireguard_interface` (e.g. `wg0`).

See [adapters/wireguard.md](adapters/wireguard.md).

### IPsec / IKEv2

- strongSwan: `swanctl --list-sas` must show active CHILD_SA.
- Legacy starter: `ipsec statusall`.

See [adapters/ipsec.md](adapters/ipsec.md).

### Cisco AnyConnect

- Requires `vpn` CLI from Cisco Secure Client.
- Run as user with active VPN profile.

See [adapters/cisco-anyconnect.md](adapters/cisco-anyconnect.md).

## GUI issues

### Linux GTK unavailable

Install `python3-gi` and `gir1.2-gtk-4.0`, or use `bash scripts/uvpn-tui`.

### macOS menu bar shows stale data

- Run `uvpn check` manually or click **Refresh** in the menu.
- State older than 12 minutes may indicate no scheduled checks — add launchd timer (see [platforms/macos/install.md](platforms/macos/install.md)).

## Permissions

- ICMP ping may require `cap_net_raw` on Linux or root for some distros.
- Cisco `vpn` CLI typically requires the logged-in user's keychain/session.

## Getting help

1. `uvpn preflight`
2. `uvpn check -v` (if verbose flag available) or inspect `state.json`
3. Open an issue with redacted `config.json` (no secrets) and last diagnosis
