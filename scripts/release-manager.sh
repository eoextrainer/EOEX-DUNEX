#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git sf
require_repo_root

cd "$ROOT_DIR"

deploy_branch() {
  local branch="$1"
  git push origin HEAD:"$branch"
}

deploy_org() {
  local alias_name="$1"
  sf project deploy start --source-dir force-app --target-org "$alias_name" --wait 60 --ignore-warnings
}

while true; do
  cat <<'EOF'

DUNEX Release Manager Menu
1. Push to int branch
2. Deploy to int org
3. Push to uat branch
4. Deploy to uat org
5. Push to prod branch
6. Deploy to prod org
7. Push to main branch
8. Exit

EOF
  read -r -p "Choose an option: " choice
  case "$choice" in
    1)
      deploy_branch int
      ;;
    2)
      deploy_org int-org
      ;;
    3)
      deploy_branch uat
      ;;
    4)
      deploy_org uat-org
      ;;
    5)
      deploy_branch prod
      ;;
    6)
      deploy_org prod-org
      ;;
    7)
      deploy_branch main
      ;;
    8)
      exit 0
      ;;
    *)
      printf 'Invalid option\n' >&2
      ;;
  esac
done
