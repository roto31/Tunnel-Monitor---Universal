#!/bin/bash
# Install uvpn LaunchAgent (macOS user session)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME}"
SUPPORT="${HOME_DIR}/Library/Application Support/uvpn"
PLIST="${HOME_DIR}/Library/LaunchAgents/com.universal.uvpn.check.plist"

mkdir -p "${SUPPORT}" "${HOME_DIR}/Library/Logs"
sed "s|__HOME__|${HOME_DIR}|g" "${SCRIPT_DIR}/com.universal.uvpn.check.plist.template" > "${PLIST}"
launchctl bootout "gui/$(id -u)" "${PLIST}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "${PLIST}"
launchctl enable "gui/$(id -u)/com.universal.uvpn.check"
echo "OK: LaunchAgent installed — checks every 300s"
echo "Config: ${SUPPORT}/config.json"
