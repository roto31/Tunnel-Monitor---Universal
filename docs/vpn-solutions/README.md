# VPN solution guides — uniform layout

Each guide incorporates **monitoring-applicable** product documentation in reworded form. **Vendor citations** (URLs) appear only in the **Citations** section at the bottom of each guide and in `manifests/*.yaml` for maintainers.

| Section | Purpose |
|---------|---------|
| **uvpn at a glance** | Adapter id, monitoring approach |
| **Incorporated reference map** | Which product manual sections are reflected (manifest ids) |
| **Visual reference** | Original topology illustration (`assets/*.png`; SVG sources alongside) |
| **Diagrams** | Mermaid — architecture, lifecycle, uvpn monitoring flow |
| **1–9 Product guide (incorporated)** | Install, CLI, lifecycle, auth, logging, exit codes, troubleshooting — reworded |
| **uvpn configuration** | `config.json` example |
| **uvpn monitoring** | Commands uvpn runs + probe combination |
| **Supported versions** | [adapter-version-matrix.md](../architecture/adapter-version-matrix.md) |
| **uvpn troubleshooting** | Operator runbook |
| **Citations** | Authoritative vendor / RFC links |
| **Related** | Internal architecture links |

**Policy:** Summaries restate established vendor facts for operators; they are not substitutes for licensed vendor manuals held by your organization.
