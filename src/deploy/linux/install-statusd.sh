#!/bin/bash
set -euo pipefail

# Install uvpn-statusd systemd unit and token file (idempotent).
# Run from repo root: sudo bash src/deploy/linux/install-statusd.sh

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "ERROR: run as root (sudo)" >&2
  exit 2
fi

if ! getent group uvpn-status >/dev/null 2>&1; then
  groupadd -r uvpn-status
fi
if ! id uvpn-status >/dev/null 2>&1; then
  useradd -r -g uvpn-status -s /usr/sbin/nologin -d /nonexistent uvpn-status
fi

mkdir -p /etc/uvpn
chmod 0750 /etc/uvpn

if [[ ! -f /etc/uvpn/status-token ]]; then
  python3 -c "import secrets; print(secrets.token_urlsafe(32))" > /etc/uvpn/status-token
  chmod 0600 /etc/uvpn/status-token
  chown root:uvpn-status /etc/uvpn/status-token
  echo "WARN: created /etc/uvpn/status-token — store securely" >&2
fi

if [[ -f "${ROOT}/scripts/uvpn-statusd" ]]; then
  install -m 0755 "${ROOT}/scripts/uvpn-statusd" /usr/local/bin/uvpn-statusd
elif command -v uvpn-statusd >/dev/null 2>&1; then
  echo "OK: uvpn-statusd already in PATH"
else
  echo "ERROR: install uvpn with portal extra first: pip install -e '.[portal]'" >&2
  exit 3
fi

install -m 0644 "${ROOT}/src/deploy/linux/uvpn-statusd.service" /etc/systemd/system/uvpn-statusd.service
systemctl daemon-reload

if [[ -f /etc/uvpn/state.json ]]; then
  chgrp uvpn-status /etc/uvpn/state.json 2>/dev/null || true
  chmod 0640 /etc/uvpn/state.json 2>/dev/null || true
fi

echo "OK: installed uvpn-statusd.service"
echo "     systemctl enable --now uvpn-statusd"
echo "     Place TLS reverse proxy per docs/deploy/status-portal.md"
