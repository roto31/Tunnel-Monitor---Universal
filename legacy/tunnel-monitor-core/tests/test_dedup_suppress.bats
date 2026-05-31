#!/usr/bin/env bats
# test_dedup_suppress.bats

setup() {
    TM_CORE="${BATS_TEST_DIRNAME}/.."
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/common.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/diagnosis.sh"
}

@test "suppress email when gateway DOWN and TUNNEL_DOWN" {
    GATEWAY_REACHABLE="true"
    GATEWAY_ALERT="DOWN"
    run tm_should_suppress_email "TUNNEL_DOWN"
    [[ "${status}" -eq 0 ]]
}

@test "never suppress for GATEWAY_UNREACHABLE" {
    GATEWAY_REACHABLE="false"
    GATEWAY_ALERT=""
    run tm_should_suppress_email "GATEWAY_UNREACHABLE"
    [[ "${status}" -eq 1 ]]
}

@test "never suppress for DISAGREEMENT" {
    GATEWAY_REACHABLE="true"
    GATEWAY_ALERT="UP"
    run tm_should_suppress_email "DISAGREEMENT"
    [[ "${status}" -eq 1 ]]
}
