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
| `check` | Run full monitoring cycle |
| `status` | Show last connection snapshot |
| `statistics` / `stats` | Probe and adapter metrics |
| `logs` | Recent VPN-related log lines |
| `diagnostics` | Diagnosis, issues, runbook (JSON) |
| `explain` | Human-readable runbook |
| `preflight` | Validate config and dependencies |
| `adapters` | List registered VPN types |
| `init-config` | Write example config |

## Related: status portal

**`uvpn-statusd`** (optional, `pip install -e ".[portal]"`) serves redacted HTTP status—it does **not** replace CLI `check`. See [../deploy/status-portal.md](../deploy/status-portal.md).

## Examples

```bash
uvpn init-config
uvpn preflight
uvpn check
uvpn status
uvpn statistics
uvpn logs
uvpn diagnostics
uvpn adapters
```

## Config fields

| Field | Required | Description |
|-------|----------|-------------|
| `vpn_type` | Yes | `generic`, `openvpn`, `wireguard`, `ipsec`, `ikev2`, `cisco_anyconnect`, `fortinet`, `globalprotect`, `pulse` |
| `remote_lan_ip` | Yes | Host on remote LAN (tunnel health) |
| `remote_wan_ip` | Recommended | Remote public IP |
| `remote_ddns` | Optional | DDNS hostname for drift detection |
| `failure_threshold` | Optional | Consecutive failures before alert (default 3) |
| `check_interval_sec` | Optional | Suggested interval (default 300) |

Adapter-specific keys: see [../vpn-solutions/](../vpn-solutions/).

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Runtime error |
| 2 | Config error |
