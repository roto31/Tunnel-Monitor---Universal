# macOS host hardening — uvpn-statusd

Prefer **per-user** portal on the Mac that runs the VPN client (Forti/Pulse/Cisco often require GUI session).

## Run locally (development / small office)

```bash
export UVPN_CONFIG_DIR="$HOME/Library/Application Support/uvpn"
export UVPN_STATUS_TOKEN_FILE="$HOME/Library/Application Support/uvpn/status-token"
chmod 0600 "$UVPN_STATUS_TOKEN_FILE"
# Generate token: python3 -c "import secrets; print(secrets.token_urlsafe(32))" > "$UVPN_STATUS_TOKEN_FILE"
export UVPN_STATUS_BIND="127.0.0.1:8080"
uvpn-statusd
```

Access from phone: Tailscale to Mac + SSH tunnel or bind Tailscale IP (see Linux nftables pattern on `utun` routes).

## Secrets

- Do **not** put Bearer tokens in LaunchAgent plist XML.
- Use a `0600` env file loaded by `launchctl` or shell wrapper.

## FileVault (PR.DS)

Enable full-disk encryption for laptop monitors—recommended OS control.

## Firewall

Use **System Settings → Network → Firewall** or `pf` to allow inbound only on Tailscale interface for the chosen port.

## TLS

Terminate with Caddy or nginx on macOS (Homebrew) listening on Tailscale IP; proxy to loopback uvicorn.
