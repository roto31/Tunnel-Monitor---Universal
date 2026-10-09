# Legacy releases (bash macOS)

> **Universal product releases:** [../RELEASES.md](../RELEASES.md) (uvpn tags `uvpn-v*`).

Download macOS builds from the GitHub **Releases** tab:

**https://github.com/roto31/Tunnel-Monitor---Universal/releases**

## Sanitized public line (UniFi site-to-site)

`legacy/Public` mirrors [UniFi-Tunnel-Monitor](https://github.com/roto31/UniFi-Tunnel-Monitor). These tags do **not** replace Universal Latest (`v2.0.0`).

| Tag | Package | Notes |
|-----|---------|--------|
| [tunnel-monitor-v1.5.0](https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/tunnel-monitor-v1.5.0) | `Tunnel-Monitor-1.5.0.pkg` | Spoke policy-route card and **Install Checker**. Developer ID signed. Notarization is not stapled until App Store Connect → Business shows the agreement Active. |
| [tunnel-monitor-v1.3.1](https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/tunnel-monitor-v1.3.1) | `Tunnel-Monitor-1.3.1.pkg` | Previous notarized public package |

Docs for 1.5.0 live in [`Public/docs/`](Public/docs/) and [`Public/mac/CHANGELOG.md`](Public/mac/CHANGELOG.md). Same text as the public repo: [v1.5.0 release notes](https://github.com/roto31/UniFi-Tunnel-Monitor/blob/v1.5.0/docs/release-notes/v1.5.0.md).

## Current Universal release: v2.0.1

| Artifact | Description |
|----------|-------------|
| `Tunnel-Monitor-2.0.1.pkg` | **Recommended** — GUI + launchd + core v2 payload |
| `Tunnel-Monitor-2.0.1-macOS.app.zip` | Menu bar app only |
| `CHECKSUMS.sha256` | SHA-256 checksums |

### What is new in v2.0.1 (GUI)

| Feature | Description |
|---------|-------------|
| **Technical detail** | Expandable runbook per diagnosis code in the menu bar popover |
| **Suggested steps** | Numbered operator actions matching core decision tree |
| **Stale banner** | Warns when `state.json` is older than ~12 minutes |
| **Schema label** | Shows `state.json` schema version (v2) |
| **Explain** | Opens Terminal → `tunnel-check --explain` |
| **Preflight** | Opens Terminal → `tunnel-check --preflight` |

Docs: [`Public/docs/v2/gui-operator-features.md`](Public/docs/v2/gui-operator-features.md)

### Install (pkg)

1. Download `Tunnel-Monitor-2.0.1.pkg` (or latest from Releases).
2. Open the pkg and enter an administrator password.
3. Edit `/opt/tunnel-monitor/config.env` — replace every `REPLACE_WITH_*` placeholder.
4. Open **Tunnel Monitor** from Applications (menu bar).
5. Verify: `tunnel-check diagnose`, `tunnel-check --preflight`, `tunnel-check --test-email`.

### Verify checksum

```bash
shasum -a 256 -c CHECKSUMS.sha256
```

### What is included

- **Tunnel Monitor.app** — SwiftUI menu bar GUI (`DiagnosisReference`, stale detection)
- **LaunchDaemon** — `monitor-engine.sh --role lan_client` every 5 minutes
- **tunnel-monitor-core v2** — vendored under `/opt/tunnel-monitor/core/`
- **operator-explain.sh** — shared CLI/GUI runbooks
- **SwiftBar plugin** — optional menu bar script (deployed by postinstall)

### Not in this release

- UniFi gateway adapter (copy from `adapters/unifi-gateway/` manually)
- Generic Linux gateway (see wiki)
- Windows LAN client (see `Public/windows/`)
- Notarized/signed build unless release notes say otherwise

---

## Previous: v2.0.0

| Artifact | Notes |
|----------|-------|
| `Tunnel-Monitor-2.0.0.pkg` | First Universal v2 distribution |
| `Tunnel-Monitor-2.0.0-macOS.app.zip` | App only; no v2.0.1 GUI runbooks |

Core v2, `gateway_dedup` schema, `GATEWAY_*` wizard keys — see [CHANGELOG.md](CHANGELOG.md).

---

## Version matrix

| Tag | Core | GUI highlights |
|-----|------|----------------|
| [v2.0.1](https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.1) | 2.0.0 | Runbooks, stale banner, Explain/Preflight |
| [v2.0.0](https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.0) | 2.0.0 | `gateway_dedup`, Liquid Glass UI |
| v1.1.0 | — | Liquid Glass assets |
| v1.0.0 | — | Initial public macOS release |

Full history: [`CHANGELOG.md`](CHANGELOG.md).

## Building from source

See [`RELEASING.md`](RELEASING.md).
