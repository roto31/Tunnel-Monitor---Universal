#!/bin/bash
# DEPRECATED: use Private/install/install.sh
set -euo pipefail
echo "DEPRECATED: use Private/install/install.sh" >&2
exec bash "$(dirname "$0")/Private/install/install.sh" "$@"
