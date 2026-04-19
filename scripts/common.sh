#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$ROOT_DIR/tmp"
REGISTRY_FILE="$ROOT_DIR/config/scratch-org-registry.csv"
DEVELOPERS_FILE="$ROOT_DIR/config/developers.csv"

mkdir -p "$TMP_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmds() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
  done
}

require_repo_root() {
  [[ -f "$ROOT_DIR/sfdx-project.json" ]] || die "Run this script inside the EOEX-DUNEX repository"
}

git_branch_exists() {
  git show-ref --verify --quiet "refs/heads/$1"
}

remote_branch_exists() {
  git ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1
}

ensure_branch_from_base() {
  local branch="$1"
  local base="$2"
  if git_branch_exists "$branch"; then
    git checkout "$branch" >/dev/null 2>&1
  else
    git checkout -b "$branch" "$base" >/dev/null 2>&1
  fi
}

sync_branch_with_origin() {
  local branch="$1"
  local base="$2"
  git fetch origin --prune >/dev/null 2>&1 || true
  if remote_branch_exists "$branch"; then
    if git_branch_exists "$branch"; then
      git checkout "$branch" >/dev/null 2>&1
      git merge --ff-only "origin/$branch" >/dev/null 2>&1 || die "Local branch $branch has diverged from origin/$branch"
    else
      git checkout -b "$branch" --track "origin/$branch" >/dev/null 2>&1
    fi
  elif ! git_branch_exists "$branch"; then
    git checkout -b "$branch" "$base" >/dev/null 2>&1
  fi
}

ensure_clean_worktree() {
  git diff --quiet || die "Working tree has unstaged changes"
  git diff --cached --quiet || die "Index has staged changes"
}

month_key() {
  date '+%Y-%m'
}

month_compact() {
  date '+%Y%m'
}

developer_field() {
  local key="$1"
  local column="$2"
  awk -F',' -v target="$key" -v column="$column" '
    NR == 1 {
      for (i = 1; i <= NF; i++) {
        if ($i == column) {
          selected = i
        }
      }
      next
    }
    $1 == target {
      print $selected
      exit
    }
  ' "$DEVELOPERS_FILE"
}

developer_email() {
  developer_field "$1" email
}

developer_base_username() {
  developer_field "$1" base_username
}

current_scratch_alias() {
  printf 'dunex-%s-%s' "$1" "$(month_key)"
}

current_scratch_username() {
  local developer_key="$1"
  printf '%s.%s@dunex.scratch' "$(developer_base_username "$developer_key")" "$(month_compact)"
}

ensure_registry_file() {
  if [[ ! -f "$REGISTRY_FILE" ]]; then
    printf 'developer_key,alias,username,password_file,month,status\n' > "$REGISTRY_FILE"
  fi
}

upsert_registry_record() {
  local developer_key="$1"
  local alias="$2"
  local username="$3"
  local password_file="$4"
  local month="$5"
  local status="$6"
  ensure_registry_file
  awk -F',' -v OFS=',' -v key="$developer_key" -v alias="$alias" -v username="$username" -v password_file="$password_file" -v month="$month" -v status="$status" '
    BEGIN {
      replaced = 0
    }
    NR == 1 {
      print $0
      next
    }
    $1 == key {
      print key, alias, username, password_file, month, status
      replaced = 1
      next
    }
    {
      print $0
    }
    END {
      if (!replaced) {
        print key, alias, username, password_file, month, status
      }
    }
  ' "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp"
  mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
}

latest_backup_month() {
  local developer_key="$1"
  git show scratch:backups/scratch/"$developer_key"/latest/.month 2>/dev/null || true
}

with_temp_worktree() {
  local branch="$1"
  local var_name="$2"
  local worktree_dir
  worktree_dir="$(mktemp -d "$TMP_DIR/${branch//\//-}.XXXXXX")"
  git worktree add --quiet "$worktree_dir" "$branch" >/dev/null 2>&1
  printf -v "$var_name" '%s' "$worktree_dir"
}

cleanup_worktree() {
  local worktree_dir="$1"
  git worktree remove --force "$worktree_dir" >/dev/null 2>&1 || true
}

metadata_ref_from_path() {
  local path="$1"
  case "$path" in
    force-app/main/default/classes/*.cls)
      printf 'ApexClass:%s\n' "$(basename "$path" .cls)"
      ;;
    force-app/main/default/triggers/*.trigger)
      printf 'ApexTrigger:%s\n' "$(basename "$path" .trigger)"
      ;;
    force-app/main/default/lwc/*/*.js-meta.xml)
      printf 'LightningComponentBundle:%s\n' "$(basename "$(dirname "$path")")"
      ;;
    force-app/main/default/aura/*/*)
      printf 'AuraDefinitionBundle:%s\n' "$(basename "$(dirname "$path")")"
      ;;
    force-app/main/default/objects/*.object-meta.xml)
      printf 'CustomObject:%s\n' "$(basename "$path" .object-meta.xml)"
      ;;
    force-app/main/default/objects/*/fields/*.field-meta.xml)
      printf 'CustomField:%s.%s\n' "$(basename "$(dirname "$(dirname "$path")")")" "$(basename "$path" .field-meta.xml)"
      ;;
    force-app/main/default/layouts/*.layout-meta.xml)
      printf 'Layout:%s\n' "$(basename "$path" .layout-meta.xml)"
      ;;
    force-app/main/default/flows/*.flow-meta.xml)
      printf 'Flow:%s\n' "$(basename "$path" .flow-meta.xml)"
      ;;
    force-app/main/default/flexipages/*.flexipage-meta.xml)
      printf 'FlexiPage:%s\n' "$(basename "$path" .flexipage-meta.xml)"
      ;;
    force-app/main/default/permissionsets/*.permissionset-meta.xml)
      printf 'PermissionSet:%s\n' "$(basename "$path" .permissionset-meta.xml)"
      ;;
    force-app/main/default/permissionSetGroups/*.permissionsetgroup-meta.xml)
      printf 'PermissionSetGroup:%s\n' "$(basename "$path" .permissionsetgroup-meta.xml)"
      ;;
    force-app/main/default/profiles/*.profile-meta.xml)
      printf 'Profile:%s\n' "$(basename "$path" .profile-meta.xml)"
      ;;
    force-app/main/default/tabs/*.tab-meta.xml)
      printf 'CustomTab:%s\n' "$(basename "$path" .tab-meta.xml)"
      ;;
    force-app/main/default/applications/*.app-meta.xml)
      printf 'CustomApplication:%s\n' "$(basename "$path" .app-meta.xml)"
      ;;
    force-app/main/default/customMetadata/*.md-meta.xml)
      printf 'CustomMetadata:%s\n' "$(basename "$path" .md-meta.xml)"
      ;;
    force-app/main/default/remoteSiteSettings/*.remoteSite-meta.xml)
      printf 'RemoteSiteSetting:%s\n' "$(basename "$path" .remoteSite-meta.xml)"
      ;;
    force-app/main/default/staticresources/*.resource-meta.xml)
      printf 'StaticResource:%s\n' "$(basename "$path" .resource-meta.xml)"
      ;;
    *)
      return 1
      ;;
  esac
}
