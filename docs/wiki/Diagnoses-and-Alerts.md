# Diagnoses and alerts (uvpn)

Universal build — diagnosis from `src/uvpn/core/diagnosis.py`. Legacy bash codes (`GATEWAY_UNREACHABLE`, `DISAGREEMENT`) are documented under [Troubleshooting-Legacy-Public](Troubleshooting-Legacy-Public).

## Diagnosis codes (first match wins)

| Code | Meaning | Typical traffic light |
|------|---------|------------------------|
| `HEALTHY` | LAN probe OK | green |
| `OUR_INTERNET_DOWN` | Local internet probe failed | yellow; counter frozen |
| `VPN_DAEMON_DOWN` | Vendor CLI: not connected / service down | yellow → red |
| `VPN_NEGOTIATION_FAILED` | CLI connected, LAN probe failed (split tunnel) | yellow → red |
| `DDNS_DRIFT` | `remote_ddns` ≠ `remote_wan_ip` | yellow → red |
| `REMOTE_INTERNET_DOWN` | `remote_wan` probe failed | yellow → red |
| `TUNNEL_DOWN` | LAN down, WAN/DNS looked OK | yellow → red |
| `UNSUPPORTED` | Missing binary / unknown layout | grey |
| `UNKNOWN` | Incomplete config / first run | grey |

**CLI:** `uvpn explain` · **GUI:** diagnosis panel after refresh · **Status portal:** `GET /api/v1/diagnostics` (redacted; Bearer auth)

When sharing externally, do not paste raw `state.json`—use [Status Portal](Status-Portal) or redact per [Security Threat Model](Security-Threat-Model).

## Legacy mapping

| Legacy (tunnel-monitor) | uvpn |
|-------------------------|------|
| `DISAGREEMENT` | `VPN_NEGOTIATION_FAILED` (when CLI says connected) |
| `TUNNEL_DOWN` | `TUNNEL_DOWN` or `VPN_NEGOTIATION_FAILED` |
| `GATEWAY_UNREACHABLE` | Not used — no gateway SSH dedup in uvpn |

## Alert timing

| Setting | Default |
|---------|---------|
| Check interval | 300 s (5 min) |
| `failure_threshold` | 3 (~15 min to DOWN) |

`OUR_INTERNET_DOWN` does not increment failure count.

## Full runbooks + flowcharts

| Topic | Wiki |
|-------|------|
| Universal decision tree | [Troubleshooting-Universal](Troubleshooting-Universal) |
| Index | [Troubleshooting](Troubleshooting) |
| Per platform | [Troubleshooting-OpenVPN](Troubleshooting-OpenVPN), [WireGuard](Troubleshooting-WireGuard), [IPsec](Troubleshooting-IPsec-IKEv2), [Cisco](Troubleshooting-Cisco-AnyConnect), [Fortinet](Troubleshooting-Fortinet), [GlobalProtect](Troubleshooting-GlobalProtect), [Pulse](Troubleshooting-Pulse-Ivanti), [Generic](Troubleshooting-Generic) |

Repo: [docs/troubleshooting/](https://github.com/roto31/Tunnel-Monitor---Universal/tree/main/docs/troubleshooting)
