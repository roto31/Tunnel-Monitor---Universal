#!/bin/bash
set -u
SCRIPT_DIR="/opt/tunnel-monitor"
exec bash "${SCRIPT_DIR}/bin/monitor-engine.sh" \
    --role gateway \
    --install-root "${SCRIPT_DIR}" \
    --adapter-dir "${SCRIPT_DIR}/adapter" \
    check
