# Enterprise adapter version matrix (v1.0.0 target)

Fixture validation uses vendor-doc-derived stdout samples in [`tests/fixtures/adapters/`](../../tests/fixtures/adapters/).

**Provenance:** vendor documentation excerpts only (no lab, no customer samples).

## GlobalProtect

| Platform | Client / tool | Supported in v1.0.0 | CLI surface | Source |
|----------|---------------|---------------------|-------------|--------|
| macOS | GlobalProtect app + `gpctl` | Yes | `gpctl show status` | [PAN GlobalProtect](https://docs.paloaltonetworks.com/globalprotect) |
| Linux | GlobalProtect agent + `gpctl` | Yes (when binary present) | `gpctl show status` | Same |

Unsupported: hosts without `gpctl` → adapter returns `supported=False`; use `vpn_type: generic`.

## FortiClient

| Platform | Client | Supported in v1.0.0 | CLI surface | Source |
|----------|--------|---------------------|-------------|--------|
| macOS | FortiClient 7.x | Yes | `fortivpn vpn status` or `forticlient vpn status` | [FortiClient docs](https://docs.fortinet.com/product/forticlient) |
| Linux | FortiClient 7.x | Yes (when CLI present) | Same | Same |

Unsupported versions: return `supported=False` when CLI missing or output unrecognized.

## Pulse / Ivanti Secure Access

| Platform | Client | Supported in v1.0.0 | CLI surface | Source |
|----------|--------|---------------------|-------------|--------|
| macOS | Ivanti Secure Access / Pulse 22.x | Yes | `pulselauncher status` or `PulseClient.sh status` | [Ivanti Product Help](https://help.ivanti.com/ps/) |
| Linux | Pulse / ISAC client | Yes (when wrapper present) | Same | [Linux CLI QSG](https://help.ivanti.com/ps/help/en_US/ISAC/vNow/linux-qsg/using-linux-client-command-line.htm) |

See [`pulse-cli-contract.md`](pulse-cli-contract.md) for exit criteria and fixture variants.

## Validation status labels

| Label | Meaning |
|-------|---------|
| Fixture-validated | Parser tested against `tests/fixtures/adapters/<vendor>/` |
| Documented-at | Command documented at vendor portal; not lab-tested |
| Lab-validated | Not available in v1.0.0 scope |

All three enterprise adapters in v1.0.0 are **fixture-validated** + **documented-at**.
