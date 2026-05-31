# CLI reference

Entry points:

```bash
uvpn              # after pip install -e .
bash scripts/uvpn # wrapper (uses .venv if present)
python3 -m uvpn   # direct module
```

## Commands

| Command | Description |
|---------|-------------|
| `init-config` | Write example `~/.config/uvpn/config.json` |
| `preflight` | Validate config and dependencies |
| `check` | Run full monitoring cycle; write `state.json` |
| `status` | Print last snapshot (JSON or human) |
| `explain` | Runbook for last diagnosis |
| `adapters` | List registered VPN adapters |

## Examples

```bash
uvpn init-config
uvpn preflight
uvpn check
uvpn status
uvpn explain
uvpn adapters
```

## Config fields

| Field | Required | Description |
|-------|----------|-------------|
| `vpn_type` | Yes | `generic`, `openvpn`, `wireguard`, `ipsec`, `ikev2`, `cisco_anyconnect` |
| `remote_lan_ip` | Yes | Host on remote LAN (tunnel health) |
| `remote_wan_ip` | Recommended | Remote public IP |
| `remote_ddns` | Optional | DDNS hostname for drift detection |
| `failure_threshold` | Optional | Consecutive failures before alert (default 3) |
| `check_interval_sec` | Optional | Suggested interval (default 300) |

Adapter-specific keys: see [../adapters/](../adapters/).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Runtime error |
| 2 | Config error |
