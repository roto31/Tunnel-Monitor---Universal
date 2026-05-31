# Pulse Secure / Ivanti Secure Access

**vpn_type:** `pulse` or `ivanti`

## Verified sources

- Pulse Secure documentation portal: https://docs.pulsesecure.net/

## Research gap

**No stable cross-platform monitoring CLI** is documented for all Pulse/Ivanti client versions. uvpn adapter attempts `pulselauncher status` heuristics when installed.

**Recommendation:** Use `"vpn_type": "generic"` for production until you validate CLI output for your exact client build.

## Config example (experimental)

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
| Connection heuristic | pulselauncher (if present) | **Not verified across versions** |
| Data plane | universal probes | Yes |
