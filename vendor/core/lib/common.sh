#!/bin/bash
# shellcheck shell=bash
# common.sh — logging, config, time helpers

tm_timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

tm_iso_now() {
    if date -Iseconds >/dev/null 2>&1; then
        date -Iseconds
    else
        date '+%Y-%m-%dT%H:%M:%S%z' | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/'
    fi
}

tm_log() {
    local level="$1"
    shift
    local line="[$(tm_timestamp)] [${level}] $*"
    if [[ -n "${TM_LOG_FILE:-}" ]]; then
        printf '%s\n' "${line}" >> "${TM_LOG_FILE}" 2>/dev/null || true
    fi
    if [[ "${TM_LOG_STDOUT:-false}" == "true" ]]; then
        printf '%s\n' "${line}"
    fi
}

tm_log_info()  { tm_log "info" "$@"; }
tm_log_warn()  { tm_log "warn" "$@"; }
tm_log_error() { tm_log "error" "$@"; }

tm_rotate_log_if_needed() {
    local max="${LOG_MAX_BYTES:-1048576}"
    [[ -n "${TM_LOG_FILE:-}" && -f "${TM_LOG_FILE}" ]] || return 0
    local size=0
    if [[ "$(uname -s)" == "Darwin" ]]; then
        size="$(stat -f '%z' "${TM_LOG_FILE}" 2>/dev/null || echo 0)"
    else
        size="$(stat -c '%s' "${TM_LOG_FILE}" 2>/dev/null || echo 0)"
    fi
    if [[ "${size}" -gt "${max}" ]]; then
        mv -f "${TM_LOG_FILE}" "${TM_LOG_FILE}.1" 2>/dev/null || true
        : > "${TM_LOG_FILE}"
        chmod 0644 "${TM_LOG_FILE}" 2>/dev/null || true
    fi
}

# Map legacy gateway SSH keys to canonical GATEWAY_* (core 2.x lifetime).
tm_normalize_gateway_config() {
    GATEWAY_HOST="${GATEWAY_HOST:-${ROUTER_HOST:-${UDR7_HOST:-}}}"
    GATEWAY_USER="${GATEWAY_USER:-${ROUTER_USER:-${UDR7_USER:-root}}}"
    GATEWAY_KEY="${GATEWAY_KEY:-${ROUTER_KEY:-${UDR7_KEY:-}}}"
    GATEWAY_STATE_PATH="${GATEWAY_STATE_PATH:-${ROUTER_STATE_PATH:-${UDR7_STATE_PATH:-/data/tunnel-monitor/state}}}"
}

tm_load_config() {
    local config_file="$1"
    if [[ ! -f "${config_file}" ]]; then
        tm_log_error "config missing: ${config_file}"
        return 2
    fi
    # shellcheck disable=SC1090
    source "${config_file}"

    REMOTE_LAN_IP="${REMOTE_LAN_IP:-192.0.2.1}"
    REMOTE_WAN_IP="${REMOTE_WAN_IP:-198.51.100.1}"
    REMOTE_DDNS="${REMOTE_DDNS:-remote.example.com}"
    FAILURE_THRESHOLD="${FAILURE_THRESHOLD:-3}"
    PING_COUNT="${PING_COUNT:-3}"
    PING_TIMEOUT="${PING_TIMEOUT:-2}"
    SUBJECT_PREFIX="${SUBJECT_PREFIX:-}"
    SITE_NAME="${SITE_NAME:-site-to-site VPN}"
    CHECK_INTERVAL_MIN="${CHECK_INTERVAL_MIN:-5}"
    NOTIFY_SOUND_DOWN="${NOTIFY_SOUND_DOWN:-Glass}"
    NOTIFY_SOUND_RECOVERY="${NOTIFY_SOUND_RECOVERY:-Hero}"
    LOG_MAX_BYTES="${LOG_MAX_BYTES:-1048576}"

    tm_normalize_gateway_config
    return 0
}

tm_validate_state_line() {
    local line="$1"
    [[ "${line}" =~ ^[0-9]+:(UP|DOWN)$ ]]
}

tm_parse_state_line() {
    local line="$1"
    GATEWAY_COUNT="${line%%:*}"
    GATEWAY_ALERT="${line##*:}"
    GATEWAY_STATE_STR="${line}"
}
