#!/usr/bin/env bats
# test_state_line.bats

setup() {
    TM_CORE="${BATS_TEST_DIRNAME}/.."
    # shellcheck source=/dev/null
    source "${TM_CORE}/lib/common.sh"
}

@test "valid state lines" {
    tm_validate_state_line "0:UP"
    tm_validate_state_line "3:DOWN"
}

@test "reject malformed state lines" {
    ! tm_validate_state_line "UP"
    ! tm_validate_state_line "3:up"
    ! tm_validate_state_line ""
}

@test "parse state line components" {
    tm_parse_state_line "3:DOWN"
    [[ "${GATEWAY_COUNT}" == "3" ]]
    [[ "${GATEWAY_ALERT}" == "DOWN" ]]
    [[ "${GATEWAY_STATE_STR}" == "3:DOWN" ]]
}
