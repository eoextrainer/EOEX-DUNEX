#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git
require_repo_root

cd "$ROOT_DIR"

log "Fetching origin"
git fetch origin --prune

sync_branch_with_origin main main
git checkout main
git pull --ff-only origin main

for branch in dev feat fix archive scratch; do
  if git_branch_exists "$branch"; then
    git checkout "$branch" >/dev/null 2>&1
    git merge --ff-only main >/dev/null 2>&1 || true
  else
    git checkout -b "$branch" main >/dev/null 2>&1
  fi
done

if remote_branch_exists release; then
  sync_branch_with_origin release main
else
  if git_branch_exists release; then
    git checkout release >/dev/null 2>&1
    git merge --ff-only main >/dev/null 2>&1 || true
  else
    git checkout -b release main >/dev/null 2>&1
  fi
fi

git checkout main >/dev/null 2>&1

log "Branch model ready: main, dev, feat, fix, archive, release, scratch"
