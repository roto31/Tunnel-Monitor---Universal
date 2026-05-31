# Threat model — uvpn-statusd (STRIDE)

**Scope:** FastAPI status portal on macOS/Linux monitoring hosts, private overlay only.  
**Out of scope:** Internet-facing SaaS, iOS agent, VPN client configuration.

---

## Assets

| Sensitivity | Asset |
|-------------|--------|
| High | `config.json` (remote IPs, DDNS), `adapter.raw`, VPN log lines in `state.json` |
| Medium | `diagnosis`, `alert_state`, `failure_count` |
| Low | `traffic_light`, `timestamp`, `schema_version` |

---

## STRIDE summary

| Threat | Example | Mitigation |
|--------|---------|------------|
| **S** Spoofing | Stolen Bearer token | Token file `0600`; rotate; optional mTLS |
| **T** Tampering | POST to trigger check | No mutation routes; 405 |
| **R** Repudiation | Denied access attempt | JSON audit log with `src_ip`, `request_id` |
| **I** Information disclosure | Full `state.json` via API | `PublicStatusDTO` redaction |
| **D** Denial of service | Flood `/api/v1/status` | Rate limit at proxy; fail-closed auth |
| **E** Elevation | Portal runs `run_check` as root | Separate OS users; API read-only |

---

## Platform-specific vectors

### Linux

- **Network:** uvicorn bound to `0.0.0.0` — use `UVPN_STATUS_BIND` on Tailscale IP + [nftables example](../../src/deploy/statusd/nftables-uvpn-statusd.nft.example).
- **systemd:** Writable unit — ship hardened unit; `systemd-analyze security`.
- **Disk:** World-readable `state.json` — `0640` group `uvpn-status`.

### macOS

- **VPN CLI session:** Forti/Pulse/Cisco may require GUI user session — run portal as same user as VPN or monitor from Linux server with `generic`.
- **Secrets in plist:** Never store Bearer token in LaunchAgent plist; use env file `0600`.

---

## Data loss prevention

1. Drop `adapter.raw` from API responses.  
2. Omit `logs` by default on `/api/v1/status`.  
3. Optional `UVPN_STATUS_MASK_IPS=1` for probe targets.  
4. Audit logs: no tokens, no response bodies.  
5. Headers: `Cache-Control: no-store`, `Content-Security-Policy: default-src 'none'` on HTML.

---

## Residual risks

See gap table in [nist-portal-architecture.md](nist-portal-architecture.md) and [verification.md](verification.md). Host compromise and single shared token remain primary operational risks.
