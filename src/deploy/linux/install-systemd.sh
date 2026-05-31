#!/bin/bash
# Install uvpn systemd timer (Linux)
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "ERROR: run as root" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install -m 0644 "${SCRIPT_DIR}/uvpn.service" /etc/systemd/system/uvpn.service
install -m 0644 "${SCRIPT_DIR}/uvpn.timer" /etc/systemd/system/uvpn.timer
mkdir -p /etc/uvpn
if [[ ! -f /etc/uvpn/config.json ]]; then
    echo "WARN: create /etc/uvpn/config.json before starting timer" >&2
fi
systemctl daemon-reload
systemctl enable --now uvpn.timer
echo "OK: uvpn.timer enabled (5min interval)"
