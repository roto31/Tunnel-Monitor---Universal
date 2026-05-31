#!/bin/bash
# shellcheck shell=bash
# diagnosis.sh — canonical decision tree

# Requires GATEWAY_REACHABLE, GATEWAY_STATE_STR set by dedup query.
# Args: tunnel_ok wan_ok our_ok dns_match (true/false strings)
tm_compute_diagnosis() {
    local tunnel_ok="$1"
    local wan_ok="$2"
    local our_ok="$3"
    local dns_match="$4"

    if [[ "${our_ok}" == "false" ]]; then
        printf 'OUR_INTERNET_DOWN'
        return
    fi
    if [[ "${tunnel_ok}" == "true" ]]; then
        printf 'HEALTHY'
        return
    fi
    if [[ "${GATEWAY_REACHABLE:-false}" != "true" ]]; then
        printf 'GATEWAY_UNREACHABLE'
        return
    fi
    if [[ "${GATEWAY_STATE_STR:-}" == "0:UP" ]]; then
        printf 'DISAGREEMENT'
        return
    fi
    if [[ "${dns_match}" == "false" ]]; then
        printf 'DDNS_DRIFT'
        return
    fi
    if [[ "${wan_ok}" == "false" ]]; then
        printf 'REMOTE_INTERNET_DOWN'
        return
    fi
    printf 'TUNNEL_DOWN'
}

tm_diagnosis_human() {
    case "$1" in
        HEALTHY)              printf '%s' 'HEALTHY' ;;
        TUNNEL_DOWN)          printf '%s' 'TUNNEL DOWN' ;;
        DDNS_DRIFT)           printf '%s' 'DDNS DRIFT — fix DDNS record' ;;
        REMOTE_INTERNET_DOWN) printf '%s' 'REMOTE INTERNET DOWN' ;;
        OUR_INTERNET_DOWN)    printf '%s' 'OUR INTERNET DOWN (no alert)' ;;
        GATEWAY_UNREACHABLE)  printf '%s' 'GATEWAY UNREACHABLE — LAN client alerting' ;;
        UDR7_UNREACHABLE|ROUTER_UNREACHABLE) printf '%s' 'GATEWAY UNREACHABLE — LAN client alerting' ;;
        DISAGREEMENT)         printf '%s' 'DISAGREEMENT (gateway says UP)' ;;
        *)                    printf '%s' "$1" ;;
    esac
}

tm_diagnosis_subject() {
    local diagnosis="$1"
    local suffix
    suffix="$(tm_diagnosis_human "${diagnosis}")"
    printf '⚠ %s Tunnel DOWN — %s' "${SITE_NAME:-Tunnel}" "${suffix}"
}

tm_should_suppress_email() {
    local diagnosis="$1"
    if [[ "${diagnosis}" == "GATEWAY_UNREACHABLE" || "${diagnosis}" == "DISAGREEMENT" ]]; then
        return 1
    fi
    if [[ "${GATEWAY_REACHABLE:-false}" == "true" && "${GATEWAY_ALERT:-}" == "DOWN" ]]; then
        return 0
    fi
    return 1
}
