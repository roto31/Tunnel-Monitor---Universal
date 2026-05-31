#!/bin/bash
# ssh-gateway-state.sh — canonical gateway dedup SSH reader (alias of ssh-router-state.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/ssh-router-state.sh" "$@"
