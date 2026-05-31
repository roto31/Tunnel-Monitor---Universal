# uvpn security documentation

Optional **read-only status portal** (`uvpn-statusd`) for private overlay access (LAN, Tailscale, site VPN). Disabled by default; install `[portal]` extra only when needed.

| Document | Purpose |
|----------|---------|
| [nist-portal-architecture.md](nist-portal-architecture.md) | NIST CSF 2.0, SP 800-53 Rev 5 Moderate mapping, SP 800-52 Rev 2 TLS |
| [threat-model.md](threat-model.md) | STRIDE threat model (macOS/Linux) |
| [ctm-portal.csv](ctm-portal.csv) | Control Traceability Matrix template |
| [verification.md](verification.md) | Audit cadence, testssl, CI evidence |
| [host-hardening-linux.md](host-hardening-linux.md) | systemd, nftables, file permissions |
| [host-hardening-macos.md](host-hardening-macos.md) | LaunchAgent, pf notes |

Deploy: [status-portal.md](../deploy/status-portal.md)

Wiki: `python3 scripts/sync-wiki-all.py` from repo root.
