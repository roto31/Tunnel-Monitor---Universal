# Enterprise adapter version matrix (v1.0.0 target)

Fixture validation uses vendor-doc-derived stdout samples in `tests/fixtures/adapters/`.

**Provenance:** Reworded excerpts from vendor administration material; fixture files capture expected CLI shapes. No external vendor URLs in operator documentation.

## GlobalProtect

| Platform | Client / tool | Supported in v1.0.0 | CLI surface | Maintainer record |
|----------|---------------|---------------------|-------------|-------------------|
| macOS | GlobalProtect app + `gpctl` | Yes | `gpctl show status` | GP 6.x admin + Linux 6.3 user CLI |
| Linux | GlobalProtect agent + CLI | Yes (when binary present) | `gpctl show status` or `globalprotect show --status` | Same |

Unsupported: hosts without CLI → `supported=False`; use `vpn_type: generic` for probes only.

## FortiClient

| Platform | Client | Supported in v1.0.0 | CLI surface | Maintainer record |
|----------|--------|---------------------|-------------|-------------------|
| macOS | FortiClient 7.x | Yes | `fortivpn` / `forticlient vpn status` | FortiClient 7.4 admin — platform CLI chapters |
| Linux | FortiClient 7.x | Yes (when CLI present) | Same | Same |

Unsupported versions: unrecognized stdout → `supported=False`.

## Pulse / Ivanti Secure Access

| Platform | Client | Supported in v1.0.0 | CLI surface | Maintainer record |
|----------|--------|---------------------|-------------|-------------------|
| macOS | ISAC 22.x | Yes | `pulselauncher status` | ISAC 22.x CLI launcher chapter |
| Linux | ISAC / Pulse client | Yes (when wrapper present) | Same + `/opt/pulsesecure/bin/pulselauncher` | ISAC Linux QSG CLI |

See [pulse-cli-contract.md](pulse-cli-contract.md).

## Validation status labels

| Label | Meaning |
|-------|---------|
| Fixture-validated | Parser tested against `tests/fixtures/adapters/<vendor>/` |
| Documented-at | Behavior restated from vendor administration material (internal record) |
| Lab-validated | Not in v1.0.0 scope |

All three enterprise adapters in v1.0.0 are **fixture-validated** + **documented-at**.
