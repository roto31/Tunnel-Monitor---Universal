# Pulse Secure / Ivanti Secure Access

**vpn_type:** `pulse` or `ivanti`

## Verified sources

- Pulse Secure documentation portal: https://docs.pulsesecure.net/
- CLI contract (documented-at): [docs/architecture/pulse-cli-contract.md](../architecture/pulse-cli-contract.md)
- Supported builds: [docs/architecture/adapter-version-matrix.md](../architecture/adapter-version-matrix.md)

## Production status

The `pulse` adapter is **production-quality for documented CLI output** (vendor-doc fixtures). It parses `pulselauncher status` (or `pulse_binary` override) and combines results with universal probes.

**Do not** rely on `generic` alone when you have Pulse/Ivanti installed — use `"vpn_type": "pulse"` so CLI state is evaluated.

Validation is **fixture-based** (no lab). Unsupported client versions return `supported=False` per the version matrix.

## Config example

```json
{
  "vpn_type": "pulse",
  "pulse_binary": "pulselauncher",
  "remote_lan_ip": "10.0.0.1",
  "remote_wan_ip": "203.0.113.1"
}
```

## Monitoring metrics

| Metric | Source | Verified |
|--------|--------|----------|
| Connection state | `pulselauncher status` (version-pinned) | Documented-at + fixtures |
| Data plane | universal probes | Yes |
