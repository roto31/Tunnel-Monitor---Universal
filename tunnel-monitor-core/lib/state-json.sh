#!/bin/bash
# shellcheck shell=bash
# state-json.sh — atomic LAN client state file

tm_state_get() {
    local path="$1"
    local default="$2"
    if [[ -f "${TM_STATE_FILE}" ]]; then
        jq -r "${path} // ${default}" "${TM_STATE_FILE}" 2>/dev/null || printf '%s' "${default//\"/}"
    else
        printf '%s' "${default//\"/}"
    fi
}

tm_write_state_json() {
    local now="$1"
    local diagnosis="$2"
    local alert_state="$3"
    local failure_count="$4"
    local last_alert="$5"
    local last_recovery="$6"
    local down_since="$7"

    local tmp="${TM_STATE_FILE}.tmp.$$"

    j_num() { if [[ -z "$1" ]]; then echo "null"; else echo "$1"; fi; }
    j_str_or_null() {
        if [[ -z "$1" || "$1" == "null" ]]; then echo "null"
        else printf '"%s"' "$1"; fi
    }

    local dedup_reach="false"
    [[ "${GATEWAY_REACHABLE:-false}" == "true" ]] && dedup_reach="true"

    if ! jq -n \
        --argjson schema_version 2 \
        --arg ts "${now}" \
        --arg diag "${diagnosis}" \
        --arg as "${alert_state}" \
        --argjson fc "${failure_count}" \
        --argjson la "$(j_str_or_null "${last_alert}")" \
        --argjson lr "$(j_str_or_null "${last_recovery}")" \
        --arg tt "${REMOTE_LAN_IP}" \
        --argjson tok $([[ "${TM_TUNNEL_OK}" == "true" ]] && echo true || echo false) \
        --argjson tlat "$(j_num "${TM_TUNNEL_LAT}")" \
        --arg wt "${REMOTE_WAN_IP}" \
        --argjson wok $([[ "${TM_WAN_OK}" == "true" ]] && echo true || echo false) \
        --argjson wlat "$(j_num "${TM_WAN_LAT}")" \
        --arg ot "1.1.1.1" \
        --argjson ook $([[ "${TM_OUR_OK}" == "true" ]] && echo true || echo false) \
        --argjson olat "$(j_num "${TM_OUR_LAT}")" \
        --arg dh "${REMOTE_DDNS}" \
        --arg dr "${TM_DNS_RESOLVED}" \
        --arg de "${REMOTE_WAN_IP}" \
        --argjson dm $([[ "${TM_DNS_MATCH}" == "true" ]] && echo true || echo false) \
        --argjson gr $([[ "${dedup_reach}" == "true" ]] && echo true || echo false) \
        --argjson gs "$(j_str_or_null "${GATEWAY_STATE_STR:-}")" \
        --arg gc "${now}" \
        --argjson ds "$(j_str_or_null "${down_since}")" \
        '{
          schema_version: $schema_version,
          timestamp: $ts,
          alert_state: $as,
          failure_count: $fc,
          down_since: $ds,
          checks: {
            tunnel:       { target: $tt, ok: $tok, latency_ms: $tlat },
            remote_wan:   { target: $wt, ok: $wok, latency_ms: $wlat },
            our_internet: { target: $ot, ok: $ook, latency_ms: $olat },
            dns: {
              host: $dh,
              resolved: $dr,
              expected: $de,
              match: $dm
            }
          },
          gateway_dedup: { reachable: $gr, state: $gs, checked_at: $gc },
          udr7_dedup:    { reachable: $gr, state: $gs, checked_at: $gc },
          router_dedup:  { reachable: $gr, state: $gs, checked_at: $gc },
          last_alert_sent_at:    $la,
          last_recovery_sent_at: $lr,
          diagnosis: $diag
        }' > "${tmp}" 2>/dev/null; then
        tm_log_error "failed to render state.json"
        rm -f -- "${tmp}"
        return 1
    fi

    if ! mv -f -- "${tmp}" "${TM_STATE_FILE}" 2>/dev/null; then
        tm_log_error "failed to install state.json"
        rm -f -- "${tmp}"
        return 1
    fi
    chmod 0644 "${TM_STATE_FILE}" 2>/dev/null || true
    return 0
}
