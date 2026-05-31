# macOS installation

## Requirements

- Python 3.11+ (`python3 --version`)
- macOS 14+ for menu bar app scaffold
- macOS 26+ recommended for Liquid Glass styling (app uses existing design tokens when built)

## Install engine

```bash
cd Tunnel-Monitor---Universal   # repo root
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
sudo ln -sf "$(pwd)/scripts/uvpn" /usr/local/bin/uvpn
uvpn init-config
nano ~/.config/uvpn/config.json
```

## CLI / terminal

```bash
uvpn check
uvpn explain
bash scripts/uvpn-tui
```

## macOS GUI

```bash
cd src/gui-macos/UniversalVPNMonitor
swift build -c release
```

The Swift app reads `~/.config/uvpn/state.json` written by the Python engine. Menu bar actions: Refresh, Run check, Explain, Preflight, Adapters.

## LaunchAgent (periodic checks)

```bash
bash src/deploy/macos/install-launchagent.sh
```

Runs `uvpn check` every 300 seconds. Config: `~/Library/Application Support/uvpn/config.json`.

## Cisco AnyConnect on macOS

Set `vpn_type` to `cisco_anyconnect` and `cisco_vpn_binary` to the Secure Client CLI path. See [../vpn-solutions/cisco-anyconnect.md](../vpn-solutions/cisco-anyconnect.md).

## Legacy note

The archived bash monitor is under `legacy/Public/mac/` — **not** the Universal product. Use **uvpn** for platform-agnostic monitoring.
