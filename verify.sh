#!/bin/bash
# DEPRECATED: use Private/install/verify.sh
set -euo pipefail
echo "DEPRECATED: use Private/install/verify.sh" >&2
exec bash "$(dirname "$0")/Private/install/verify.sh" "$@"
