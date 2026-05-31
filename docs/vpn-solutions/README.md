# VPN solution guides — uniform layout

Your organization picked a VPN product; uvpn does not replace it—it **listens** to it. Each guide below rewords vendor material you already have into what matters for monitoring: install paths, CLI status commands, and the gap between “connected” and “I can reach the thing I need.”

Each guide incorporates **monitoring-applicable** product documentation in reworded form. **Vendor citations** (URLs) appear only in the **Citations** section at the bottom of each guide and in `manifests/*.yaml` for maintainers.

| Section | Purpose |
|---------|---------|
| **uvpn at a glance** | Adapter id, monitoring approach |
| **Incorporated reference map** | Which product manual sections are reflected (manifest ids) |
| **Visual reference** | Original topology illustration (`assets/*.png`; SVG sources alongside) |
| **Diagrams** | Mermaid — architecture, lifecycle, uvpn monitoring flow (includes optional [statusd](../deploy/status-portal.md) read path) |
| **1–9 Product guide (incorporated)** | Install, CLI, lifecycle, auth, logging, exit codes, troubleshooting — reworded |
| **uvpn configuration** | `config.json` example |
| **uvpn monitoring** | Commands uvpn runs + probe combination |
| **Supported versions** | [adapter-version-matrix.md](../architecture/adapter-version-matrix.md) |
| **uvpn troubleshooting** | Operator runbook |
| **Citations** | Authoritative vendor / RFC links |
| **Related** | Internal architecture links |

**Policy:** Summaries restate established vendor facts for operators; they are not substitutes for licensed vendor manuals held by your organization.

**Wiki:** GitHub Wiki pages are generated from these files. After editing a guide, run:

```bash
python3 scripts/sync-wiki-vpn-guides.py
```

Commit both the repo guide and `.wiki-publish/` (or push the wiki remote).

**Operational security:** Monitoring exposes topology in `config.json` and `state.json`. Optional mobile access uses the [status portal](../deploy/status-portal.md) with NIST-aligned controls in [../security/](../security/README.md)—not raw file sharing.

**Troubleshooting:** Full runbooks with Mermaid flowcharts — [../troubleshooting/README.md](../troubleshooting/README.md). Wiki: `python3 scripts/sync-wiki-troubleshooting.py`.
