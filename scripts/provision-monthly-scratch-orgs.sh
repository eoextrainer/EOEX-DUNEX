#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git sf awk mkdir tar
require_repo_root

cd "$ROOT_DIR"

devhub_alias="${DEVHUB_ALIAS:-}"
[[ -n "$devhub_alias" ]] || die "Set DEVHUB_ALIAS before running this script"

mkdir -p "$ROOT_DIR/config/generated-passwords"
ensure_registry_file

restore_latest_backup() {
  local developer_key="$1"
  local target_alias="$2"
  local backup_month
  local worktree_dir

  backup_month="$(latest_backup_month "$developer_key")"
  [[ -n "$backup_month" ]] || return 0

  log "Restoring backup $backup_month for $developer_key"
  with_temp_worktree scratch worktree_dir
  backup_root="$worktree_dir/backups/scratch/$developer_key/$backup_month"
  if [[ -d "$backup_root/metadata" ]]; then
    sf project deploy start --metadata-dir "$backup_root/metadata/unpackaged" --target-org "$target_alias" --wait 60 --ignore-warnings
  fi
  if [[ -f "$backup_root/data/data-plan.json" ]]; then
    sf data import tree --plan "$backup_root/data/data-plan.json" --target-org "$target_alias"
  fi
  cleanup_worktree "$worktree_dir"
}

git fetch origin --prune
sync_branch_with_origin main main
git checkout main
git pull --ff-only origin main

tail -n +2 "$DEVELOPERS_FILE" | while IFS=',' read -r developer_key _ developer_email _; do
  alias_name="$(current_scratch_alias "$developer_key")"
  username="$(current_scratch_username "$developer_key")"
  password_file="$ROOT_DIR/config/generated-passwords/$alias_name.txt"

  log "Creating scratch org $alias_name for $developer_key"
  sf org create scratch \
    --target-dev-hub "$devhub_alias" \
    --definition-file "$ROOT_DIR/config/project-scratch-def.json" \
    --alias "$alias_name" \
    --duration-days 30 \
    --wait 30 \
    --admin-email "$developer_email" \
    --username "$username"

  sf project deploy start --source-dir force-app --target-org "$alias_name" --wait 60 --ignore-warnings
  restore_latest_backup "$developer_key" "$alias_name"
  sf org generate password --target-org "$alias_name" --length 24 >/dev/null
  sf org display user --target-org "$alias_name" --json > "$password_file"

  upsert_registry_record "$developer_key" "$alias_name" "$username" "$password_file" "$(month_key)" active
done

log "Monthly scratch org provisioning complete"
