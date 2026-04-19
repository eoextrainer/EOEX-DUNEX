#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds sf

to_instance_url() {
  local url="$1"
  if [[ "$url" =~ ^https://([^.]+)\.trailblaze\.lightning\.force\.com/?$ ]]; then
    printf 'https://%s.my.salesforce.com\n' "${BASH_REMATCH[1]}"
  else
    printf '%s\n' "$url"
  fi
}

is_authorized() {
  local alias_name="$1"
  sf org display --target-org "$alias_name" >/dev/null 2>&1
}

declare -a aliases=(
  "int-org|https://brave-goat-8vbdse-dev-ed.trailblaze.lightning.force.com/"
  "uat-org|https://cunning-moose-9keyzh-dev-ed.trailblaze.lightning.force.com/"
  "prod-org|https://curious-bear-g70af2-dev-ed.trailblaze.lightning.force.com/"
  "dev-sandbox-org|https://creative-raccoon-cqx65l-dev-ed.trailblaze.lightning.force.com/"
)

for item in "${aliases[@]}"; do
  alias_name="${item%%|*}"
  url="${item##*|}"
  instance_url="$(to_instance_url "$url")"
  if is_authorized "$alias_name"; then
    log "Skipping $alias_name; already authenticated"
    continue
  fi
  log "Authenticating $alias_name"
  sf org login web --alias "$alias_name" --instance-url "$instance_url"
done

log "Shared org aliases authenticated"
