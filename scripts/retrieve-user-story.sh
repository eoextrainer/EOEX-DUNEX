#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git sf tar cp
require_repo_root

cd "$ROOT_DIR"

story_id="${1:-}"
story_type="${2:-}"
developer_key="${3:-}"

[[ -n "$story_id" && -n "$story_type" && -n "$developer_key" ]] || die "Usage: $0 US-XXX feat|fix developer-key"
[[ "$story_type" == "feat" || "$story_type" == "fix" ]] || die "Story type must be feat or fix"

story_branch="${story_type}-${story_id}"
story_dir="$ROOT_DIR/manifest/user-stories/$story_id"
package_file="$story_dir/package.xml"
scratch_alias="$(current_scratch_alias "$developer_key")"
archive_patch="$TMP_DIR/${story_branch}.patch"

[[ -f "$package_file" ]] || die "Missing generated package.xml: $package_file"
git checkout "$story_branch"

log "Retrieving metadata from $scratch_alias"
sf project retrieve start --manifest "$package_file" --target-org "$scratch_alias" --ignore-conflicts --wait 60

if git diff --quiet && git diff --cached --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  die "No retrieved changes were detected for $story_branch"
fi

stash_name="${story_branch}-$(date '+%Y%m%d%H%M%S')"
git stash push -u -m "$stash_name" >/dev/null
git stash show -p stash@{0} > "$archive_patch"
git stash pop --index >/dev/null || true

git add force-app manifest docs sfdx-project.json
git diff --cached --quiet && die "Retrieved changes did not produce a committable diff for $story_branch"

git commit -m "${story_type}(${story_id}): retrieved from $scratch_alias"
commit_sha="$(git rev-parse HEAD)"

if ! git_branch_exists archive; then
  git checkout -b archive main >/dev/null 2>&1
fi

with_temp_worktree archive archive_worktree
trap 'cleanup_worktree "$archive_worktree"' EXIT

archive_root="$archive_worktree/archives/user-stories/$story_id/$(date '+%Y%m%d-%H%M%S')"
mkdir -p "$archive_root"
git archive --format=tar.gz -o "$archive_root/${story_branch}.tar.gz" "$story_branch"
cp "$archive_patch" "$archive_root/${story_branch}.patch"
cp "$story_dir/story.txt" "$archive_root/story.txt"
[[ -f "$story_dir/metadata-analysis.txt" ]] && cp "$story_dir/metadata-analysis.txt" "$archive_root/metadata-analysis.txt"
printf '%s\n' "$commit_sha" > "$archive_root/commit-sha.txt"

cd "$archive_worktree"
git add "archives/user-stories/$story_id"
git commit -m "archive(${story_id}): snapshot ${commit_sha:0:8}" >/dev/null 2>&1 || true
cd "$ROOT_DIR"

"$SCRIPT_DIR/promote-user-story.sh" "$story_branch" "$story_type"

log "User story retrieval, archive, and promotion complete"
