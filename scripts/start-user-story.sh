#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git sf
require_repo_root

cd "$ROOT_DIR"

story_id="${1:-}"
story_type="${2:-}"
developer_key="${3:-}"

[[ -n "$story_id" && -n "$story_type" && -n "$developer_key" ]] || die "Usage: $0 US-XXX feat|fix developer-key"
[[ "$story_type" == "feat" || "$story_type" == "fix" ]] || die "Story type must be feat or fix"
[[ -n "$(developer_email "$developer_key")" ]] || die "Unknown developer key: $developer_key"

story_dir="$ROOT_DIR/manifest/user-stories/$story_id"
[[ -f "$story_dir/story.txt" ]] || die "Missing $story_dir/story.txt"

story_branch="${story_type}-${story_id}"
scratch_alias="$(current_scratch_alias "$developer_key")"

git fetch origin --prune
sync_branch_with_origin main main
git checkout main
git pull --ff-only origin main

ensure_branch_from_base "$story_type" main
git merge --ff-only main >/dev/null 2>&1 || true

if git_branch_exists "$story_branch"; then
  git checkout "$story_branch"
  git merge --no-edit "$story_type" >/dev/null 2>&1 || true
else
  git checkout -b "$story_branch" "$story_type"
fi

"$SCRIPT_DIR/generate-package.sh" "$story_id"

log "Opening scratch org $scratch_alias"
sf org open --target-org "$scratch_alias" || log "Scratch org open skipped. Check whether $scratch_alias is authenticated."

log "User story branch ready: $story_branch"
