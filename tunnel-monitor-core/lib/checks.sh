#!/bin/bash
# shellcheck shell=bash
# checks.sh — ping and DNS probes (platform-aware)

# tm_check_ping <target> -> echoes latency ms or empty; rc 0 ok, 1 fail
tm_check_ping() {
    local target="$1"
    local out latency=""

    if [[ "$(uname -s)" == "Darwin" ]]; then
        local timeout_ms=$(( PING_TIMEOUT * 1000 ))
        if out="$(ping -c "${PING_COUNT}" -W "${timeout_ms}" -q "${target}" 2>/dev/null)"; then
            latency="$(printf '%s\n' "${out}" | awk -F'/' '/min\/avg\/max/ {print $5}' | awk '{print $1}')"
            latency="${latency%.*}"
            printf '%s' "${latency}"
            return 0
        fi
    else
        if out="$(ping -c "${PING_COUNT}" -W "${PING_TIMEOUT}" -q "${target}" 2>/dev/null)"; then
            latency="$(printf '%s' "${out}" | awk -F'/' '/rtt|round-trip/ {print $5}' | head -1)"
            latency="${latency%.*}"
            [[ -z "${latency}" ]] && latency="0"
            printf '%s' "${latency}"
            return 0
        fi
    fi
    printf ''
    return 1
}

# tm_check_ping_bool — gateway role (no latency)
tm_check_ping_bool() {
    local target="$1"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        local timeout_ms=$(( PING_TIMEOUT * 1000 ))
        ping -c "${PING_COUNT}" -W "${timeout_ms}" -q "${target}" >/dev/null 2>&1
    else
        ping -c "${PING_COUNT}" -W "${PING_TIMEOUT}" -q "${target}" >/dev/null 2>&1
    fi
}

tm_resolve_ddns() {
    local host="${1:-${REMOTE_DDNS}}"
    local r=""
    r="$(dig +short +time=3 +tries=1 "${host}" @1.1.1.1 2>/dev/null \
        | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' \
        | head -1)"
    if [[ -z "${r}" ]]; then
        r="$(dig +short +time=3 +tries=1 "${host}" 2>/dev/null \
            | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' \
            | head -1)"
    fi
    printf '%s' "${r}"
}

tm_run_health_checks() {
    TM_TUNNEL_OK="false"
    TM_WAN_OK="false"
    TM_OUR_OK="false"
    TM_DNS_MATCH="false"
    TM_TUNNEL_LAT=""
    TM_WAN_LAT=""
    TM_OUR_LAT=""
    TM_DNS_RESOLVED=""

    if TM_TUNNEL_LAT="$(tm_check_ping "${REMOTE_LAN_IP}")"; then TM_TUNNEL_OK="true"; fi
    if TM_WAN_LAT="$(tm_check_ping "${REMOTE_WAN_IP}")"; then TM_WAN_OK="true"; fi
    if TM_OUR_LAT="$(tm_check_ping "1.1.1.1")"; then TM_OUR_OK="true"; fi

    TM_DNS_RESOLVED="$(tm_resolve_ddns "${REMOTE_DDNS}")"
    if [[ -n "${TM_DNS_RESOLVED}" && "${TM_DNS_RESOLVED}" == "${REMOTE_WAN_IP}" ]]; then
        TM_DNS_MATCH="true"
    fi
}
