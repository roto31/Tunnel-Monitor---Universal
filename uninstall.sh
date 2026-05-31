#!/bin/bash
# DEPRECATED: use Private/install/uninstall.sh
set -euo pipefail
echo "DEPRECATED: use Private/install/uninstall.sh" >&2
exec bash "$(dirname "$0")/Private/install/uninstall.sh" "$@"
