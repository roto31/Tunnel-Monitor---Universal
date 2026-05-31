# Legacy bash tunnel-monitor (v2)

**Status:** Archived. Maintained for operators still running the UniFi/site-specific stack.

The **Universal product** is **uvpn** at the repository root — Python engine, plugin adapters, CLI/TUI/GTK/Swift. See [README.md](../README.md).

## What this is

| Path | Role |
|------|------|
| `legacy/Public/` | Sanitized deploy bundles (mac, linux, unifi) |
| `legacy/vendor/core/` | Bash engine (`monitor-engine.sh`, diagnosis, dedup) |
| `legacy/adapters/` | UniFi gateway, generic Linux gateway, LAN clients |
| `legacy/tunnel-monitor-core/` | Publish tree for standalone core releases |

## Quick start (legacy Mac LAN client)

```bash
cd legacy/Public/mac
sudo bash install.sh
sudo nano /opt/tunnel-monitor/config.env
tunnel-check --test-email
```

## Documentation

- Engine contract: [vendor/core/CONTRACT.md](vendor/core/CONTRACT.md)
- Convergence notes: [docs-v2/CONVERGENCE.md](docs-v2/CONVERGENCE.md)
- Operator docs: [Public/docs/](Public/docs/)
- Releases: [RELEASES.md](RELEASES.md)
- Changelog: [CHANGELOG-legacy.md](CHANGELOG-legacy.md)

## Tests

```bash
bats legacy/vendor/core/tests/
bash legacy/scripts/vendor-core.sh verify
```

## Do not use for new deployments

New point-to-point VPN monitoring should use **uvpn** with the appropriate adapter (`openvpn`, `wireguard`, `ipsec`, `cisco_anyconnect`, or `generic`).
