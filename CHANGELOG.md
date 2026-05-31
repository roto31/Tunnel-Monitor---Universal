# Changelog

All notable changes to the **private Mac Studio** tunnel-monitor stack are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versions follow [SemVer](https://semver.org/spec/v2.0.0.html).
Bundled app data revisions are listed in [`datasets/bundle-manifest.json`](datasets/bundle-manifest.json).

## [Unreleased]

### Code

- **tunnel-monitor-core v2.0.0** — portable engine under `vendor/core/` (`monitor-engine.sh`, shared `lib/`, bats CI).
- **Adapters** — `adapters/unifi-gateway/`, `adapters/generic-linux-gateway/`, `adapters/lan-client-*`.
- Mac/Linux `monitor.sh` thin wrappers; dual-write `gateway_dedup` + legacy dedup keys in `state.json`.
- Swift app decodes `gateway_dedup`; maps `GATEWAY_UNREACHABLE` / legacy diagnosis codes.
- `scripts/install-core.sh`, `scripts/vendor-core.sh`, root `bundle-manifest.json` (`coreVersion` 2.0.0).
- Publish tree `tunnel-monitor-core/` for standalone GitHub repo export.

### Build/CI

- `.github/workflows/core-ci.yml` — shellcheck + bats on `vendor/core/`.

## [1.1.0] - 2026-05-31

### Code

- **Liquid Glass** menu bar UI (`LiquidGlassDesign.swift`) with Reduce Transparency fallback.
- **Automated Liquid Glass icon** via `build/generate-liquid-glass-icon.sh` (`actool` / `ictool`).
- **`build/install-app.sh`** and Xcode project path with widget extension target.
- **Versioned release folders** under `build/releases/` with `archive-release.sh`.

### Data

- **`dataRevision`**: `wizard-fields` site-v2, `liquid-glass-v1` icon + `Assets.car` (see bundle manifest).

## [1.0.0] - 2026-05-12

### Code

- Initial SwiftUI menu bar app, launchd monitor, SwiftBar plugin, `tunnel-check` CLI.
- **`build/build-app.sh`** / **`build/build-pkg.sh`** packaging pipeline.

### Data

- **`dataRevision`**: `wizard-fields` site-v1, legacy `AppIcon.icns`.

---

## Documentation / DevOps — 2026-05-25 (continued)

### Code / docs

- **Internal documentation package** under [`internal/`](internal/): production
  topology, Mac/UDR7 application reference, incident history, decision trees,
  workflow diagrams, private↔public map.
- **Public documentation expansion** under [`Public/docs/`](Public/docs/):
  getting-started, implementation-guide, troubleshooting (beginner + advanced),
  network-overview; updated [`architecture.md`](Public/docs/architecture.md) for
  OpenVPN + WAN Guard.
- **Sanitized** [`Public/unifi/wan-guard/config-additions.env`](Public/unifi/wan-guard/config-additions.env)
  placeholders for public release.

## Documentation / DevOps — 2026-05-25

### Code / docs

- **OpenVPN fallback guide** for Comcast-class gateways that silently block
  IPsec: [`Public/docs/openvpn-site-to-site-migration.md`](Public/docs/openvpn-site-to-site-migration.md)
  references Ubiquiti’s official OpenVPN Site-to-Site KB plus community checklists,
  WAN binding notes on dual-WAN Banana, DMZ-vs-port-forward guidance, policy
  routing edits, rollback, and throughput caveats — no changes to bundled data.
- **`scripts/gen-openvpn-s2s-key-remote.sh`** shells into the Banana UDR7 (or any
  `UDR7_SSH_*` overrides) and streams the concatenated UniFi-required 512-hex-char
  static key using Ubiquiti’s `openvpn --genkey … | egrep -o '[0-9a-f]{32}'`
  extraction pattern ([Ubiquiti Help Center](https://help.ui.com/hc/en-us/articles/12646699585047-UniFi-Gateway-OpenVPN-Site-to-Site)).
- **README§10** mirrors the shortcut link so tunnel-monitor operators locate the
  runbook beside the simulated failure drills.
- **`tunnel-check --ssh-test`** re-invokes **`sudo`** when run as non-root so
  operators can probe **`0750`** `ssh-udr7-state.sh` (POSIX **`-x`** fails for login
  users who are outside `wheel`); behaviour matches **`--check-now`**.

### Data / docs

- **WAN Guard package** imported to [`Public/unifi/wan-guard/`](Public/unifi/wan-guard/)
  (UDR7 DDNS CGNAT guard; survives firmware under `/data/wan-guard/`).
- **[`Public/docs/wan-guard-openvpn-failover.md`](Public/docs/wan-guard-openvpn-failover.md)**
  documents Midco→T-Mobile failover impact on **`Home-OpenVPN`**, install steps,
  UniFi settings (disable WAN1 DDNS, WAN2 binding), operator runbook, and integration
  with tunnel-monitor. OpenVPN migration doc cross-linked.

---

## Initial build notes — 2026-05-11

Implementation details for the first monitor scripts (see also [1.0.0]):

- **`monitor.sh` uses `set -uo pipefail` (no `-e`) with an `EXIT` trap that
  forces `exit 0`.** The spec mandates monitor.sh always exit 0 so launchd
  never throttles the job.
- **`notify.sh` runs `osascript` directly when invoked by the console user
  (e.g. `tunnel-check --test-notify`), and routes through `launchctl asuser
  <uid> osascript ...` when invoked by the root daemon.**
- **`com.ruter.tunnel-monitor.plist` puts `/opt/homebrew/bin` ahead of
  `/usr/local/bin` in PATH** so root-launched `monitor.sh` finds `jq` on
  Apple Silicon.
- **`ssh-udr7-state.sh` validates the remote state line against
  `^[0-9]+:(UP|DOWN)$`** before printing it.
- **UDR7 state is queried on every check**, not only when the tunnel is down.
