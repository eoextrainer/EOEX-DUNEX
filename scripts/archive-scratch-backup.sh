#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git sf awk cp
require_repo_root

cd "$ROOT_DIR"

target_developer="${1:-all}"
ensure_registry_file
git fetch origin --prune

if ! git_branch_exists scratch; then
  git checkout -b scratch main >/dev/null 2>&1
fi

with_temp_worktree scratch backup_worktree
trap 'cleanup_worktree "$backup_worktree"' EXIT

export_for_developer() {
  local developer_key="$1"
  local alias_name="$2"
  local backup_month
  local backup_root
  local data_dir
  local query_file
  local query_name

  backup_month="$(month_key)"
  backup_root="$backup_worktree/backups/scratch/$developer_key/$backup_month"
  data_dir="$backup_root/data"

  rm -rf "$backup_root"
  mkdir -p "$backup_root/metadata" "$data_dir"

  log "Retrieving metadata backup for $developer_key from $alias_name"
  sf project retrieve start \
    --manifest "$ROOT_DIR/manifest/package.xml" \
    --target-org "$alias_name" \
    --target-metadata-dir "$backup_root/metadata" \
    --unzip \
    --wait 60

  for query_file in "$ROOT_DIR"/config/data-export-queries/*.soql; do
    [[ -f "$query_file" ]] || continue
    query_name="$(basename "$query_file" .soql)"
    sf data export tree --query "$query_file" --plan --prefix "$query_name" --output-dir "$data_dir" --target-org "$alias_name"
  done

  latest_dir="$backup_worktree/backups/scratch/$developer_key/latest"
  rm -rf "$latest_dir"
  mkdir -p "$latest_dir"
  cp -R "$backup_root/metadata" "$latest_dir/"
  cp -R "$data_dir" "$latest_dir/"
  printf '%s\n' "$backup_month" > "$latest_dir/.month"

  cd "$backup_worktree"
  git add "backups/scratch/$developer_key"
  if ! git diff --cached --quiet; then
    git commit -m "backup($developer_key): scratch org snapshot $backup_month"
  fi
  cd "$ROOT_DIR"
}

tail -n +2 "$REGISTRY_FILE" | while IFS=',' read -r developer_key alias_name _ _ month status; do
  [[ "$status" == "active" ]] || continue
  [[ "$target_developer" == "all" || "$target_developer" == "$developer_key" ]] || continue
  export_for_developer "$developer_key" "$alias_name"
done

log "Scratch backups committed to local scratch branch"
