# Changelog — Legacy bash tunnel-monitor

Archived changelog for the **legacy** macOS distribution (`Tunnel Monitor.app` + `Tunnel-Monitor.pkg` + launchd payload).

The **Universal product** changelog is at [../CHANGELOG.md](../CHANGELOG.md).

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2.0.1] — 2026-05-31

### Code

- GUI: `DiagnosisReference` runbooks; stale `state.json` banner; Explain/Preflight actions.
- CLI: `tunnel-check --explain` and `--preflight`.

### Data

- `dataRevision`: `gui-runbooks-v1`

## [2.0.0] — 2026-05-31

### Code

- tunnel-monitor-core v2 — shared `monitor-engine.sh`
- Adapters: UniFi gateway, generic Linux gateway, macOS/Linux LAN clients
- Swift menu bar app with `gateway_dedup` schema v2

## [1.0.0] — 2026-05-12

- Initial public macOS menu bar app + launchd monitor

[2.0.1]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.1
[2.0.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v2.0.0
[1.0.0]: https://github.com/roto31/Tunnel-Monitor---Universal/releases/tag/v1.0.0
