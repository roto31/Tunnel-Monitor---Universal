#!/usr/bin/env bats
# test_state_json.bats

setup() {
    TM_CORE="${BATS_TEST_DIRNAME}/.."
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/common.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/checks.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/diagnosis.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/state-json.sh"

    TM_STATE_FILE="${BATS_TMPDIR}/state.json"
    TM_LOG_FILE="${BATS_TMPDIR}/monitor.log"
    REMOTE_LAN_IP="192.168.0.1"
    REMOTE_WAN_IP="203.0.113.1"
    REMOTE_DDNS="remote.example.com"
    TM_TUNNEL_OK="true"
    TM_WAN_OK="true"
    TM_OUR_OK="true"
    TM_DNS_MATCH="true"
    TM_TUNNEL_LAT="10"
    TM_WAN_LAT="20"
    TM_OUR_LAT="5"
    TM_DNS_RESOLVED="203.0.113.1"
    GATEWAY_REACHABLE="true"
    GATEWAY_STATE_STR="0:UP"
}

@test "write_state_json includes schema_version and triple dedup keys" {
    tm_write_state_json "2026-05-30T12:00:00-05:00" "HEALTHY" "UP" 0 null null ""
    [[ -f "${TM_STATE_FILE}" ]]
    run jq -e '.schema_version == 2' "${TM_STATE_FILE}"
    [[ "${status}" -eq 0 ]]
    run jq -e '.gateway_dedup.reachable == true' "${TM_STATE_FILE}"
    [[ "${status}" -eq 0 ]]
    run jq -e '.udr7_dedup.state == "0:UP"' "${TM_STATE_FILE}"
    [[ "${status}" -eq 0 ]]
    run jq -e '.router_dedup.state == "0:UP"' "${TM_STATE_FILE}"
    [[ "${status}" -eq 0 ]]
}
