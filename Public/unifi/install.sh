#!/bin/bash
# =============================================================================
# Tunnel Monitor Installer
# Run as root on the UniFi gateway:  bash install.sh
# Re-run after firmware updates to restore (since UniFi can wipe /etc/systemd/)
# =============================================================================

set -euo pipefail

TARGET_DIR="/data/tunnel-monitor"
SYSTEMD_DIR="/etc/systemd/system"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing tunnel monitor to ${TARGET_DIR}"
mkdir -p "$TARGET_DIR"

# Copy persistent files
install -m 0755 "${SOURCE_DIR}/monitor.sh"          "${TARGET_DIR}/monitor.sh"
install -m 0755 "${SOURCE_DIR}/openvpn-recover.sh"  "${TARGET_DIR}/openvpn-recover.sh"
install -m 0700 "${SOURCE_DIR}/send-email.sh"       "${TARGET_DIR}/send-email.sh"
install -m 0755 "${SOURCE_DIR}/tunnel-check"        "${TARGET_DIR}/tunnel-check"

# tunnel-monitor-core + gateway adapter (bundled from monorepo when present)
MONOREPO_ROOT="$(cd "${SOURCE_DIR}/../.." && pwd)"
if [[ -f "${MONOREPO_ROOT}/scripts/install-core.sh" ]]; then
    # shellcheck source=../../scripts/install-core.sh
    source "${MONOREPO_ROOT}/scripts/install-core.sh"
    install_tunnel_monitor_core "${TARGET_DIR}" "${MONOREPO_ROOT}"
    install_gateway_adapter "${TARGET_DIR}" "${SOURCE_DIR}"
elif [[ -d "${SOURCE_DIR}/vendor/core" ]]; then
    # shellcheck source=/dev/null
    source "${SOURCE_DIR}/install-core-bundle.sh" 2>/dev/null || true
fi

# Preserve existing config if present; otherwise drop template
if [[ ! -f "${TARGET_DIR}/config.env" ]]; then
    install -m 0600 "${SOURCE_DIR}/config.env.template" "${TARGET_DIR}/config.env"
    echo "==> Config template installed to ${TARGET_DIR}/config.env"
    echo "    EDIT THIS FILE NOW and fill in SMTP_PASSWORD before continuing."
else
    echo "==> Existing config.env preserved at ${TARGET_DIR}/config.env"
fi

# Initialize state if missing
[[ -f "${TARGET_DIR}/state" ]] || echo "0:UP" > "${TARGET_DIR}/state"
chmod 0644 "${TARGET_DIR}/state"
[[ -f "${TARGET_DIR}/recover-state" ]] || echo "0:0:0" > "${TARGET_DIR}/recover-state"
chmod 0644 "${TARGET_DIR}/recover-state"

# Install systemd units
install -m 0644 "${SOURCE_DIR}/tunnel-monitor.service"  "${SYSTEMD_DIR}/tunnel-monitor.service"
install -m 0644 "${SOURCE_DIR}/tunnel-monitor.timer"    "${SYSTEMD_DIR}/tunnel-monitor.timer"
install -m 0644 "${SOURCE_DIR}/openvpn-recover.service" "${SYSTEMD_DIR}/openvpn-recover.service"
install -m 0644 "${SOURCE_DIR}/openvpn-recover.timer"   "${SYSTEMD_DIR}/openvpn-recover.timer"

# Symlink the diagnostic CLI into /usr/local/bin so you can just type `tunnel-check`
ln -sf "${TARGET_DIR}/tunnel-check" /usr/local/bin/tunnel-check

# Reload systemd and enable timer
systemctl daemon-reload
systemctl enable --now tunnel-monitor.timer
systemctl enable --now openvpn-recover.timer

echo
echo "==> Installation complete."
echo
echo "Next steps:"
echo "  1. Edit ${TARGET_DIR}/config.env and replace every REPLACE_WITH_*"
echo "     value (especially SMTP_PASSWORD — generate an app-specific"
echo "     password with your SMTP provider; do NOT use your account password)."
echo
echo "  2. Test the email pipeline:"
echo "       tunnel-check --test-email"
echo
echo "  3. Watch the live monitor logs:"
echo "       tunnel-check --tail"
echo
echo "  4. Trigger a one-shot check immediately:"
echo "       systemctl start tunnel-monitor.service"
echo "       journalctl -u tunnel-monitor.service --no-pager -n 30"
echo
echo "  5. See timer status:"
echo "       systemctl list-timers tunnel-monitor.timer openvpn-recover.timer"
echo
echo "  6. OpenVPN self-recovery (disabled until RECOVER_ENABLED=1 in config.env):"
echo "       ${TARGET_DIR}/openvpn-recover.sh --status"
echo "       systemctl start openvpn-recover.service"
