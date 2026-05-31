#!/usr/bin/env bats
# test_diagnosis.bats — canonical diagnosis tree

setup() {
    TM_CORE="${BATS_TEST_DIRNAME}/.."
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/common.sh"
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/diagnosis.sh"
    GATEWAY_REACHABLE="false"
    GATEWAY_STATE_STR=""
}

@test "OUR_INTERNET_DOWN when local internet fails" {
    [[ "$(tm_compute_diagnosis false false false true)" == "OUR_INTERNET_DOWN" ]]
}

@test "HEALTHY when tunnel up" {
    [[ "$(tm_compute_diagnosis true false true true)" == "HEALTHY" ]]
}

@test "GATEWAY_UNREACHABLE when SSH dedup fails" {
    GATEWAY_REACHABLE="false"
    [[ "$(tm_compute_diagnosis false true true true)" == "GATEWAY_UNREACHABLE" ]]
}

@test "DISAGREEMENT when gateway reports 0:UP" {
    GATEWAY_REACHABLE="true"
    GATEWAY_STATE_STR="0:UP"
    [[ "$(tm_compute_diagnosis false true true true)" == "DISAGREEMENT" ]]
}

@test "DDNS_DRIFT when DNS mismatch" {
    GATEWAY_REACHABLE="true"
    GATEWAY_STATE_STR="3:DOWN"
    [[ "$(tm_compute_diagnosis false true true false)" == "DDNS_DRIFT" ]]
}

@test "REMOTE_INTERNET_DOWN when remote WAN down" {
    GATEWAY_REACHABLE="true"
    GATEWAY_STATE_STR="1:UP"
    [[ "$(tm_compute_diagnosis false false true true)" == "REMOTE_INTERNET_DOWN" ]]
}

@test "TUNNEL_DOWN default" {
    GATEWAY_REACHABLE="true"
    GATEWAY_STATE_STR="2:UP"
    [[ "$(tm_compute_diagnosis false true true true)" == "TUNNEL_DOWN" ]]
}
