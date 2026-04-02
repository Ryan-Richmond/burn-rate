#!/usr/bin/env bash

set -euo pipefail

FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
export PATH="$FLUTTER_ROOT/bin:$PATH"

if [ ! -x "$FLUTTER_ROOT/bin/flutter" ]; then
  bash scripts/vercel_install_flutter.sh
fi

flutter build web --release
