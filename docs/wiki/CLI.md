# CLI

Full guide: [docs/platform-linux/cli-usage.md](https://github.com/roto31/Tunnel-Monitor---Universal/blob/main/docs/platform-linux/cli-usage.md)

## Commands

```bash
uvpn init-config
uvpn preflight
uvpn check
uvpn status
uvpn statistics    # alias: stats
uvpn logs
uvpn diagnostics
uvpn explain
uvpn adapters
```

## Wrapper

```bash
bash scripts/uvpn check
```

Uses `.venv` Python when present.

## Exit codes

- `check` returns 1 when diagnosis is not HEALTHY (expected for monitoring scripts).

## Status portal (optional)

```bash
pip install -e ".[portal]"
uvpn-statusd   # requires UVPN_STATUS_TOKEN_FILE — see Status Portal
```

HTTP API mirrors `status` / `diagnostics` with DLP redaction; does not run `check`. Security: [Security](Security).
