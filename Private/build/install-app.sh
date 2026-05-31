#!/bin/bash
# Install build/dist/Tunnel Monitor.app to /Applications (requires prior build-app.sh).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="${APP_BUNDLE:-${ROOT_DIR}/build/dist/Tunnel Monitor.app}"
DEST="/Applications/Tunnel Monitor.app"

red()   { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
green() { printf '\033[1;32m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[1;33m%s\033[0m\n' "$*"; }

show_help() {
    cat <<'EOF'
install-app.sh — install Tunnel Monitor.app to /Applications

USAGE
    bash build/build-app.sh
    bash build/install-app.sh

Requires a prior successful build at build/dist/Tunnel Monitor.app.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ ! -d "${APP_BUNDLE}/Contents/MacOS" ]]; then
    red "ERROR: app bundle not found: ${APP_BUNDLE}"
    red "Run: bash build/build-app.sh"
    exit 1
fi

if [[ "$(uname)" != "Darwin" ]]; then
    red "ERROR: macOS only"
    exit 1
fi

yellow "Stopping running Tunnel Monitor (if any)…"
osascript -e 'tell application "Tunnel Monitor" to quit' 2>/dev/null || true
pkill -x TunnelMonitor 2>/dev/null || true
sleep 1

green "Installing to ${DEST}"
sudo rm -rf "${DEST}"
sudo ditto "${APP_BUNDLE}" "${DEST}"
sudo chown -R root:wheel "${DEST}"
sudo chmod -R go-w "${DEST}"
sudo xattr -cr "${DEST}" 2>/dev/null || xattr -cr "${DEST}" 2>/dev/null || true

if [[ -f "${DEST}/Contents/Resources/Assets.car" ]]; then
    green "Liquid Glass Assets.car installed"
fi
if [[ -f "${DEST}/Contents/Resources/AppIcon.icns" ]]; then
    green "Legacy AppIcon.icns installed"
fi

green "Installed ${DEST}"
echo "Open from the menu bar or: open -a \"${DEST}\""
