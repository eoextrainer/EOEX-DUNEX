#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git mkdir
require_repo_root

cd "$ROOT_DIR"

bundle_id="${1:-}"
shift || true
[[ -n "$bundle_id" && "$#" -gt 0 ]] || die "Usage: $0 BUNDLE-ID <commit> [commit ...]"

bundle_branch="bundle/$bundle_id"
release_notes="$ROOT_DIR/docs/releases/${bundle_id}.md"

mkdir -p "$ROOT_DIR/docs/releases"
git fetch origin --prune

git checkout release
git pull --ff-only origin release

if git_branch_exists "$bundle_branch"; then
  git branch -D "$bundle_branch" >/dev/null 2>&1
fi

git checkout -b "$bundle_branch" release
git cherry-pick --no-commit "$@"
git commit -m "release($bundle_id): bundled story promotion"

cat > "$release_notes" <<EOF
# Release Bundle $bundle_id

Generated: $(date '+%Y-%m-%d %H:%M:%S')

Included commits:
$(printf -- '- %s\n' "$@")

Release manager must complete the full release note content before promotion.
EOF

git add "$release_notes"
git commit --amend --no-edit

log "Release bundle branch created: $bundle_branch"
