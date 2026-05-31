#!/bin/bash
# =============================================================================
# OpenVPN tunnel self-recovery (UniFi gateway)
# =============================================================================
# Complements monitor.sh (alert-only). When RECOVER_ENABLED=1, reloads OpenVPN
# after local + remote WAN gates pass, with exponential backoff.
#
# Install: bash install.sh (copies to /data/tunnel-monitor/, enables timer)
# Config:  see config.env.template (RECOVER_* and PEER_TUNNEL_IP)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="/data/tunnel-monitor"
CONFIG_FILE="${SCRIPT_DIR}/config.env"
STATE_FILE="${SCRIPT_DIR}/recover-state"
LOG_TAG="openvpn-recover"

usage() {
    cat <<'EOF'
openvpn-recover.sh — WAN-gated OpenVPN reload with backoff

Usage:
  openvpn-recover.sh          Run one recovery evaluation (default)
  openvpn-recover.sh --help   Show this help
  openvpn-recover.sh --status Print recover state and tunnel probes

Requires /data/tunnel-monitor/config.env with RECOVER_ENABLED=1 to perform heals.
EOF
}

log() {
    local level="$1"
    shift
    logger -t "$LOG_TAG" -p "user.${level}" "$*"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] $*"
}

die_config() {
    echo "ERROR: $*" >&2
    exit 2
}

# ---- Load config ------------------------------------------------------------
if [[ ! -f "${CONFIG_FILE}" ]]; then
    die_config "Config file missing: ${CONFIG_FILE}"
fi
# shellcheck disable=SC1090
source "${CONFIG_FILE}"

RECOVER_ENABLED="${RECOVER_ENABLED:-0}"
PEER_TUNNEL_IP="${PEER_TUNNEL_IP:-}"
REMOTE_LAN_IP="${REMOTE_LAN_IP:-}"
REMOTE_WAN_IP="${REMOTE_WAN_IP:-}"
WAN_BIND_IP="${WAN_BIND_IP:-}"
SITE_ROLE="${SITE_ROLE:-hub}"
PING_COUNT="${PING_COUNT:-2}"
PING_TIMEOUT="${PING_TIMEOUT:-3}"
RECOVER_MAX_BACKOFF="${RECOVER_MAX_BACKOFF:-900}"
RECOVER_VERIFY_SECONDS="${RECOVER_VERIFY_SECONDS:-90}"
if [[ -z "${PEER_TUNNEL_IP}" ]]; then
    die_config "PEER_TUNNEL_IP must be set in config.env"
fi

# ---- State: last_epoch:backoff_seconds:heal_attempts --------------------------
read_state() {
    if [[ -f "${STATE_FILE}" ]]; then
        cat "${STATE_FILE}"
    else
        echo "0:0:0"
    fi
}

write_state() {
    local tmp="${STATE_FILE}.$$.tmp"
    echo "$1" > "${tmp}"
    mv "${tmp}" "${STATE_FILE}"
}

parse_state() {
    local raw="$1"
    LAST_ATTEMPT_EPOCH="${raw%%:*}"
    local rest="${raw#*:}"
    BACKOFF_SECONDS="${rest%%:*}"
    HEAL_ATTEMPTS="${rest##*:}"
}

# ---- Checks -----------------------------------------------------------------
tun_interface_present() {
    ip link show type tun 2>/dev/null | grep -q 'state UP' \
        || ip link show tun0 &>/dev/null \
        || ip link show tun1 &>/dev/null
}

check_ping() {
    local target="$1"
    local bind_args=()
    if [[ -n "${WAN_BIND_IP}" ]]; then
        bind_args=(-I "${WAN_BIND_IP}")
    fi
    ping "${bind_args[@]}" -c "${PING_COUNT}" -W "${PING_TIMEOUT}" -q "${target}" >/dev/null 2>&1
}

tunnel_healthy() {
    tun_interface_present || return 1
    check_ping "${PEER_TUNNEL_IP}" || return 1
    if [[ -n "${REMOTE_LAN_IP}" ]]; then
        check_ping "${REMOTE_LAN_IP}" || return 1
    fi
    return 0
}

local_wan_healthy() {
    check_ping "1.1.1.1"
}

remote_wan_reachable() {
    if [[ -z "${REMOTE_WAN_IP}" ]]; then
        return 0
    fi
    check_ping "${REMOTE_WAN_IP}"
}

pick_backoff() {
    local attempts="$1"
    local sec=0
    case "${attempts}" in
        0|1) sec=0 ;;
        2) sec=120 ;;
        3) sec=300 ;;
        4) sec=600 ;;
        *) sec="${RECOVER_MAX_BACKOFF}" ;;
    esac
    if [[ "${sec}" -gt "${RECOVER_MAX_BACKOFF}" ]]; then
        sec="${RECOVER_MAX_BACKOFF}"
    fi
    echo "${sec}"
}

reload_openvpn() {
    if command -v ubnt-systool >/dev/null 2>&1; then
        if ubnt-systool restartService openvpn 2>/dev/null; then
            return 0
        fi
    fi
    local pid=""
    pid="$(pgrep -x openvpn 2>/dev/null | head -1 || true)"
    if [[ -n "${pid}" ]]; then
        kill -HUP "${pid}" 2>/dev/null && return 0
    fi
    log err "No openvpn process found to reload"
    return 1
}

verify_tunnel() {
    local waited=0
    local interval=5
    while [[ "${waited}" -lt "${RECOVER_VERIFY_SECONDS}" ]]; do
        if tunnel_healthy; then
            return 0
        fi
        sleep "${interval}"
        waited=$((waited + interval))
    done
    return 1
}

print_status() {
    local raw
    raw="$(read_state)"
    parse_state "${raw}"
    echo "site_role=${SITE_ROLE} recover_enabled=${RECOVER_ENABLED}"
    echo "state last_epoch=${LAST_ATTEMPT_EPOCH} backoff=${BACKOFF_SECONDS} attempts=${HEAL_ATTEMPTS}"
    echo "tun_present=$(tun_interface_present && echo yes || echo no)"
    echo "peer_tunnel_ping=$(check_ping "${PEER_TUNNEL_IP}" && echo ok || echo fail)"
    if [[ -n "${REMOTE_LAN_IP}" ]]; then
        echo "remote_lan_ping=$(check_ping "${REMOTE_LAN_IP}" && echo ok || echo fail)"
    fi
    echo "local_wan=$(local_wan_healthy && echo ok || echo fail)"
    echo "remote_wan=$(remote_wan_reachable && echo ok || echo fail)"
    echo "tunnel_healthy=$(tunnel_healthy && echo yes || echo no)"
}

run_recover() {
    local raw now
    raw="$(read_state)"
    parse_state "${raw}"
    now="$(date +%s)"

    if tunnel_healthy; then
        if [[ "${HEAL_ATTEMPTS}" -ne 0 ]]; then
            log info "Tunnel healthy — resetting recover state (was ${HEAL_ATTEMPTS} heal attempts)"
        fi
        write_state "0:0:0"
        return 0
    fi

    if [[ "${RECOVER_ENABLED}" != "1" ]]; then
        log notice "Tunnel down; RECOVER_ENABLED is not 1 — skipping heal"
        return 0
    fi

    if ! local_wan_healthy; then
        log notice "Tunnel down; local WAN unhealthy — defer heal (${SITE_ROLE})"
        return 0
    fi

    if ! remote_wan_reachable; then
        log notice "Tunnel down; remote WAN ${REMOTE_WAN_IP} unreachable — defer heal"
        return 0
    fi

    local next_allowed=$((LAST_ATTEMPT_EPOCH + BACKOFF_SECONDS))
    if [[ "${LAST_ATTEMPT_EPOCH}" -ne 0 && "${now}" -lt "${next_allowed}" ]]; then
        log notice "Tunnel down; backoff active (${BACKOFF_SECONDS}s, until epoch ${next_allowed})"
        return 0
    fi

    local new_attempts=$((HEAL_ATTEMPTS + 1))
    local new_backoff
    new_backoff="$(pick_backoff "${new_attempts}")"

    log warning "Tunnel down — reload attempt ${new_attempts} (backoff next ${new_backoff}s)"
    if ! reload_openvpn; then
        write_state "${now}:${new_backoff}:${new_attempts}"
        return 1
    fi

    if verify_tunnel; then
        log info "Tunnel recovered after reload (attempt ${new_attempts})"
        write_state "0:0:0"
        return 0
    fi

    log warning "Reload attempt ${new_attempts} failed verification within ${RECOVER_VERIFY_SECONDS}s"
    write_state "${now}:${new_backoff}:${new_attempts}"
    return 1
}

main() {
    case "${1:-}" in
        --help|-h)
            usage
            exit 0
            ;;
        --status)
            print_status
            exit 0
            ;;
        "")
            run_recover
            ;;
        *)
            echo "ERROR: Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
}

main "$@"
