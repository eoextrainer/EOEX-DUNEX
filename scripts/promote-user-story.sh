#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git
require_repo_root

cd "$ROOT_DIR"

story_branch="${1:-}"
story_type="${2:-}"
[[ -n "$story_branch" && -n "$story_type" ]] || die "Usage: $0 feat-US-XXX feat|fix"

source_branch="$story_branch"
for target_branch in "$story_type" dev release; do
  git checkout "$target_branch"
  git merge --no-ff --no-edit "$source_branch"
  source_branch="$target_branch"
done

git push origin release
git checkout "$story_branch"

log "Promotion complete for $story_branch"
