#!/bin/bash
# shellcheck shell=bash
# dedup.sh — gateway state via SSH script or env injection (tests)

tm_reset_gateway_dedup() {
    GATEWAY_REACHABLE="false"
    GATEWAY_STATE_STR=""
    GATEWAY_COUNT="0"
    GATEWAY_ALERT=""
}

tm_query_gateway_dedup() {
    tm_reset_gateway_dedup
    local line=""

    if [[ -n "${TM_GATEWAY_STATE_INJECT:-}" ]]; then
        line="${TM_GATEWAY_STATE_INJECT}"
    elif [[ -n "${TM_SSH_GATEWAY_SCRIPT:-}" && -x "${TM_SSH_GATEWAY_SCRIPT}" ]]; then
        line="$(bash "${TM_SSH_GATEWAY_SCRIPT}" 2>/dev/null)" || line=""
    elif [[ -n "${TM_SSH_GATEWAY_SCRIPT:-}" && -f "${TM_SSH_GATEWAY_SCRIPT}" ]]; then
        line="$(bash "${TM_SSH_GATEWAY_SCRIPT}" 2>/dev/null)" || line=""
    fi

    line="$(printf '%s' "${line}" | tr -d '[:space:]')"
    if [[ -n "${line}" ]] && tm_validate_state_line "${line}"; then
        GATEWAY_REACHABLE="true"
        tm_parse_state_line "${line}"
    fi
}
