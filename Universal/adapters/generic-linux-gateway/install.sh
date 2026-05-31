#!/bin/bash
# =============================================================================
# install.sh — generic Linux gateway adapter (systemd + /opt/tunnel-monitor)
# =============================================================================
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="/opt/tunnel-monitor"
SYSTEMD_DIR="/etc/systemd/system"
MONOREPO_ROOT="$(cd "${SOURCE_DIR}/../../.." && pwd)"

echo "==> Installing generic-linux gateway monitor to ${TARGET_DIR}"
mkdir -p "${TARGET_DIR}"

install -m 0755 "${SOURCE_DIR}/monitor.sh" "${TARGET_DIR}/monitor.sh"
install -m 0700 "${SOURCE_DIR}/send-email.sh" "${TARGET_DIR}/send-email.sh"
install -m 0755 "${SOURCE_DIR}/tunnel-check" "${TARGET_DIR}/tunnel-check" 2>/dev/null || true

if [[ -f "${MONOREPO_ROOT}/Universal/scripts/install-core.sh" ]]; then
    # shellcheck source=../../Universal/scripts/install-core.sh
    source "${MONOREPO_ROOT}/Universal/scripts/install-core.sh"
    install_tunnel_monitor_core "${TARGET_DIR}" "${MONOREPO_ROOT}"
    install_gateway_adapter "${TARGET_DIR}" "${SOURCE_DIR}"
fi

[[ -f "${TARGET_DIR}/config.env" ]] || install -m 0600 "${SOURCE_DIR}/config.env.template" "${TARGET_DIR}/config.env"
[[ -f "${TARGET_DIR}/state" ]] || echo "0:UP" > "${TARGET_DIR}/state"

if [[ -f "${SOURCE_DIR}/tunnel-monitor.service" ]]; then
    install -m 0644 "${SOURCE_DIR}/tunnel-monitor.service" "${SYSTEMD_DIR}/tunnel-monitor.service"
    install -m 0644 "${SOURCE_DIR}/tunnel-monitor.timer" "${SYSTEMD_DIR}/tunnel-monitor.timer"
    systemctl daemon-reload
    systemctl enable --now tunnel-monitor.timer
fi

echo "==> Done. Edit ${TARGET_DIR}/config.env then: systemctl start tunnel-monitor.service"
