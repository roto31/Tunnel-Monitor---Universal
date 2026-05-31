# Changelog — Universal VPN Monitor (uvpn)

All notable changes to the **uvpn** Python product at the repository root.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [SemVer](https://semver.org/).

Legacy bash monitor history: [legacy/CHANGELOG-legacy.md](legacy/CHANGELOG-legacy.md).

## [1.0.0] — 2026-05-30

### Added

- **Adapter test harness:** fixture-based tests for Fortinet, GlobalProtect, and Pulse (`tests/fixtures/adapters/`).
- **Enterprise adapters (production):** version-pinned CLI parsers with `PRODUCTION_VALIDATED` flag.
- **Scheduling:** `src/deploy/linux/` (systemd service + timer) and `src/deploy/macos/` (LaunchAgent template + installers).
- **GUI parity:** Explain, Preflight, and Adapters actions on Linux GTK/tkinter and macOS menu bar.
- **macOS UX:** stale-state banner (>12 min), action sheet for CLI output.
- **Docs:** adapter version matrix, Pulse CLI contract, fixture provenance policy.
- **Release workflow:** `.github/workflows/uvpn-release.yml` for `uvpn-v*` tags.

### Changed

- **0.2.0 retroactive label:** development pre-release; 1.0.0 is first production gate.
- Dynamic config paths (`UVPN_CONFIG_DIR`) for tests and deployed units.
- Pulse guide no longer recommends `generic` over the Pulse adapter.

[1.0.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/uvpn-v1.0.0

## [0.2.0] — 2026-05-31

> **Pre-release:** shipped during development; superseded by 1.0.0 production gate.

### Added

- **MonitorAPI** platform abstraction layer (`src/uvpn/api/`).
- CLI: `statistics`, `logs`, `diagnostics` commands.
- Enterprise heuristic adapters: Fortinet, GlobalProtect, Pulse/Ivanti.
- Linux tkinter fallback GUI; GTK4 tabbed GUI with full MonitorView.
- macOS Liquid Glass styling (macOS 26+) with statistics/logs in menu bar.
- Repository restructure: `src/`, `docs/architecture|platform-*|vpn-solutions/`.
- Expanded cited VPN research and per-vendor configuration guides.

### Changed

- Universal terminal menu exposes all monitoring capabilities (8 options).
- Version bump; pytest coverage for MonitorAPI.

[0.2.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/uvpn-v0.2.0

## [0.1.0] — 2026-05-31

### Added

- **Core:** `MonitorEngine` with universal ICMP/DDNS probes and atomic `state.json` writes.
- **Adapters:** OpenVPN, WireGuard, IPsec/IKEv2 (strongSwan), Cisco AnyConnect, generic reachability.
- **Diagnosis:** HEALTHY, TUNNEL_DOWN, REMOTE_INTERNET_DOWN, DDNS_DRIFT, OUR_INTERNET_DOWN, VPN_DAEMON_DOWN, VPN_NEGOTIATION_FAILED, UNSUPPORTED_VPN_TYPE.
- **Interfaces:** Python CLI (`uvpn`), bash TUI (`uvpn-tui`), Linux GTK4 GUI scaffold, macOS Swift menu bar reader.
- **Docs:** Architecture (Mermaid), cited VPN platform research, per-adapter and per-platform guides.
- **CI:** `uvpn-ci.yml` — pytest + Swift build on macOS.

### Changed

- **Repository layout:** uvpn promoted to root; legacy bash stack moved to `legacy/`.
- **Product definition:** "Universal" now means platform-agnostic Python uvpn, not renamed bash fork.

### Build / CI

- Legacy release workflow paths updated to `legacy/Public/`.

[0.1.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/uvpn-v0.1.0
