# Changelog

All notable changes to the **Tunnel Monitor — Universal** macOS distribution
(`Tunnel Monitor.app` + `Tunnel-Monitor.pkg` + launchd payload).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [SemVer](https://semver.org/).

## [2.0.0] — 2026-05-31

### Code

- **tunnel-monitor-core v2** — shared `monitor-engine.sh` with `gateway` and `lan_client` roles.
- Canonical diagnosis enum including `GATEWAY_UNREACHABLE` (replaces `UDR7_*` / `ROUTER_*` emit paths).
- LAN client `state.json` **schema v2** with `gateway_dedup` (legacy keys dual-written).
- Adapters: UniFi gateway, generic Linux gateway, macOS/Linux LAN clients.
- Swift menu bar app decodes `gateway_dedup` with v1 fallback.

### Data

- `wizard-fields.json`: `GATEWAY_*` keys and aliases for setup wizard.
- `dataRevision`: `gateway-v2` (see `Public/datasets/bundle-manifest.json`).

### Build / CI

- Monorepo reorganized into `Private/`, `Public/`, `Universal/`; docs and wiki moved under category folders (`Private/docs/`, `Public/wiki/`, `Universal/docs/wiki/`).
- Added folder-structure rule, skill, and `Universal/scripts/validate-folder-structure.sh`.
- Release artifacts archived under `Public/builds/releases/03-v2.0.0/`.

### Install

- **Recommended:** download `Tunnel-Monitor-2.0.0.pkg` from [Releases](https://github.com/roto31/Tunnel-Monitor---Universal/releases).
- Configure `/opt/tunnel-monitor/config.env` after install (see wiki [Configuration](https://github.com/roto31/Tunnel-Monitor---Universal/wiki/Configuration)).

## [1.1.0] — 2026-05-31

### Data

- Liquid Glass UI assets (`Assets.car`, actool icon pipeline).

## [1.0.0] — 2026-05-12

### Code

- Initial public macOS menu bar app + launchd monitor.

[2.0.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.0
[1.1.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v1.1.0
[1.0.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v1.0.0
