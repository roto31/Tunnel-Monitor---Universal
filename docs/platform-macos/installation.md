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

Set in `config.json`:

```json
{
  "vpn_type": "cisco_anyconnect",
  "cisco_vpn_binary": "/opt/cisco/secureclient/bin/vpn",
  "remote_lan_ip": "10.0.0.1",
  "remote_wan_ip": "198.51.100.1"
}
```

Source: [Cisco Secure Client CLI](https://www.cisco.com/c/en/us/td/docs/security/vpn_client/anyconnect/Cisco-Secure-Client-5/admin/guide/b-cisco-secure-client-admin-guide-5-0/customize-localize-anyconnect.html)

## Legacy note

The archived bash monitor is under `legacy/Public/mac/` — **not** the Universal product. Use **uvpn** for platform-agnostic monitoring.
