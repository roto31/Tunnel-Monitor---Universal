# Enterprise adapter version matrix (v1.0.0 target)

Fixture validation uses vendor-doc-derived stdout samples in `tests/fixtures/adapters/`.

**Provenance:** Reworded excerpts from vendor administration material; fixture files capture expected CLI shapes. Authoritative URLs are in each platform guide **Citations** section and `docs/vpn-solutions/manifests/`.

## GlobalProtect

| Platform | Client / tool | Supported in v1.0.0 | CLI surface | Citations |
|----------|---------------|---------------------|-------------|-----------|
| macOS | GlobalProtect app + `gpctl` | Yes | `gpctl show status` | [GP Linux CLI 6.3](https://docs.paloaltonetworks.com/globalprotect/user-guide/6-3/globalprotect-app-for-linux/use-the-globalprotect-app-for-linux) · [Admin overview](https://docs.paloaltonetworks.com/globalprotect/administration/globalprotect-overview) |
| Linux | GlobalProtect agent + CLI | Yes (when binary present) | `gpctl show status` or `globalprotect show --status` | Same |

Unsupported: hosts without CLI → `supported=False`; use `vpn_type: generic` for probes only.

## FortiClient

| Platform | Client | Supported in v1.0.0 | CLI surface | Citations |
|----------|--------|---------------------|-------------|-----------|
| macOS | FortiClient 7.x | Yes | `fortivpn` / `forticlient vpn status` | [Linux CLI 7.4.7](https://docs.fortinet.com/document/forticlient/7.4.7/administration-guide/41299/forticlient-linux-cli-commands) · [Windows CLI 7.4.7](https://docs.fortinet.com/document/forticlient/7.4.7/administration-guide/95591/forticlient-windows-cli-commands) |
| Linux | FortiClient 7.x | Yes (when CLI present) | Same | Same |

Unsupported versions: unrecognized stdout → `supported=False`.

## Pulse / Ivanti Secure Access

| Platform | Client | Supported in v1.0.0 | CLI surface | Citations |
|----------|--------|---------------------|-------------|-----------|
| macOS | ISAC 22.x | Yes | `pulselauncher status` | [CLI launcher](https://help.ivanti.com/ps/help/en_US/ISAC/22.X/ag-22.X/cli_launcher.htm) · [Linux QSG](https://help.ivanti.com/ps/help/en_US/ISAC/vNow/linux-qsg/using-linux-client-command-line.htm) |
| Linux | ISAC / Pulse client | Yes (when wrapper present) | Same + `/opt/pulsesecure/bin/pulselauncher` | Same |

See [pulse-cli-contract.md](pulse-cli-contract.md).

## Validation status labels

| Label | Meaning |
|-------|---------|
| Fixture-validated | Parser tested against `tests/fixtures/adapters/<vendor>/` |
| Documented-at | Behavior restated from vendor administration material |
| Lab-validated | Not in v1.0.0 scope |

All three enterprise adapters in v1.0.0 are **fixture-validated** + **documented-at**.
