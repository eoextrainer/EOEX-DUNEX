#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/wiki"
TARGET_DIR="$ROOT_DIR/tmp/wikio-branch"
LOCAL_README_FILE="$TARGET_DIR/README.local.md"
COMMIT_MESSAGE="docs(wiki): refresh local wikio branch"
PUSH_CHANGES=1
WIKI_URL=""
MODE="full"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: bash scripts/refresh-wikio-branch.sh [options]

Options:
  --wiki-url <url>         Override the derived GitHub Wiki remote URL
  --commit-message <text>  Commit message to use in the dedicated wiki clone
  --status                 Show current dedicated clone status and stop
  --pull-only              Refresh the local clone from the live wiki and stop
  --sync-only              Sync and commit locally, but do not push
  --no-push                Refresh the local clone and commit, but do not push
  --help                   Show this help text
EOF
}

require_cmds() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
  done
}

derive_wiki_url() {
  local origin_url
  origin_url="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null)" || die "Unable to read git origin URL"
  origin_url="${origin_url%.git}"

  case "$origin_url" in
    git@*:*/*)
      printf '%s.wiki.git\n' "$origin_url"
      ;;
    https://*/*/*|http://*/*/*|ssh://*/*/*)
      printf '%s.wiki.git\n' "$origin_url"
      ;;
    *)
      die "Unsupported origin URL format: $origin_url"
      ;;
  esac
}

ensure_git_identity() {
  local name email
  name="$(git -C "$ROOT_DIR" config user.name || true)"
  email="$(git -C "$ROOT_DIR" config user.email || true)"

  if [[ -z "$name" || -z "$email" ]]; then
    name="$(git config --global user.name || true)"
    email="$(git config --global user.email || true)"
  fi

  [[ -n "$name" ]] || die "Git user.name is not configured"
  [[ -n "$email" ]] || die "Git user.email is not configured"

  git -C "$TARGET_DIR" config user.name "$name"
  git -C "$TARGET_DIR" config user.email "$email"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --wiki-url)
        [[ $# -ge 2 ]] || die "--wiki-url requires a value"
        WIKI_URL="$2"
        shift 2
        ;;
      --commit-message)
        [[ $# -ge 2 ]] || die "--commit-message requires a value"
        COMMIT_MESSAGE="$2"
        shift 2
        ;;
      --status)
        MODE="status"
        PUSH_CHANGES=0
        shift
        ;;
      --pull-only)
        MODE="pull-only"
        PUSH_CHANGES=0
        shift
        ;;
      --sync-only)
        MODE="sync-only"
        PUSH_CHANGES=0
        shift
        ;;
      --no-push)
        PUSH_CHANGES=0
        shift
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done
}

ensure_clone() {
  if [[ -d "$TARGET_DIR/.git" ]]; then
    log "Refreshing existing dedicated wiki clone"
    git -C "$TARGET_DIR" remote set-url origin "$WIKI_URL"
    git -C "$TARGET_DIR" fetch origin --prune >/dev/null
  else
    rm -rf "$TARGET_DIR"
    mkdir -p "$(dirname "$TARGET_DIR")"
    log "Cloning dedicated wiki repository into $TARGET_DIR"
    git clone "$WIKI_URL" "$TARGET_DIR" >/dev/null
  fi
}

prepare_branch() {
  if git -C "$TARGET_DIR" show-ref --verify --quiet refs/remotes/origin/master; then
    git -C "$TARGET_DIR" checkout -B wikio origin/master >/dev/null
  else
    git -C "$TARGET_DIR" checkout --orphan wikio >/dev/null
    git -C "$TARGET_DIR" rm -rf . >/dev/null 2>&1 || true
  fi
}

print_status() {
  local current_branch current_head remote_head dirty_state readme_state

  current_branch="$(git -C "$TARGET_DIR" branch --show-current 2>/dev/null || true)"
  current_head="$(git -C "$TARGET_DIR" rev-parse --short HEAD 2>/dev/null || printf 'none')"
  remote_head="$(git -C "$TARGET_DIR" rev-parse --short origin/master 2>/dev/null || printf 'none')"

  if [[ -n "$(git -C "$TARGET_DIR" status --short 2>/dev/null || true)" ]]; then
    dirty_state="dirty"
  else
    dirty_state="clean"
  fi

  if [[ -f "$LOCAL_README_FILE" ]]; then
    readme_state="present"
  else
    readme_state="missing"
  fi

  printf 'wikio_target=%s\n' "$TARGET_DIR"
  printf 'wiki_remote=%s\n' "$WIKI_URL"
  printf 'current_branch=%s\n' "${current_branch:-detached}"
  printf 'local_head=%s\n' "$current_head"
  printf 'origin_master=%s\n' "$remote_head"
  printf 'working_tree=%s\n' "$dirty_state"
  printf 'readme_local=%s\n' "$readme_state"
}

sync_content() {
  log "Syncing repository wiki content into $TARGET_DIR"
  rsync -a --delete --exclude '.git/' --exclude 'README.local.md' "$SOURCE_DIR/" "$TARGET_DIR/"
}

ensure_local_readme() {
  if [[ -f "$LOCAL_README_FILE" ]]; then
    return 0
  fi

  cat > "$LOCAL_README_FILE" <<'EOF'
# Local Wikio Clone

This file is for the local workstation copy in `tmp/wikio-branch`.

Purpose:

- explain why this clone exists
- show the safe refresh and publish path
- avoid accidental edits in the wrong repository

What this directory is:

- a dedicated local clone of the live GitHub Wiki repository
- the place where the local `wikio` branch is refreshed and pushed to wiki `master`

What this directory is not:

- not the main EOEX-DUNEX application repository
- not the source of truth for wiki authoring

Source of truth:

- edit wiki content in the main repository `wiki/` folder first
- then refresh this clone from the main repository helper script

Safe usage:

```bash
cd "/Users/eoex/Documents/EOEX/EOEX CONSULTING/SFDC/EOEX-DUNEX"
bash scripts/refresh-wikio-branch.sh
```

Useful modes:

```bash
bash scripts/refresh-wikio-branch.sh --pull-only
bash scripts/refresh-wikio-branch.sh --sync-only
```

Notes:

- this file is intentionally local-only
- the refresh helper preserves `README.local.md` during sync
- avoid hand-editing wiki pages here unless you intentionally want to work directly in the dedicated clone
EOF
}

commit_if_needed() {
  git -C "$TARGET_DIR" add --all
  git -C "$TARGET_DIR" reset -- README.local.md >/dev/null 2>&1 || true

  if git -C "$TARGET_DIR" diff --cached --quiet; then
    log "No wikio changes detected"
    return 1
  fi

  log "Creating wikio commit"
  git -C "$TARGET_DIR" commit -m "$COMMIT_MESSAGE" >/dev/null
  return 0
}

push_if_requested() {
  if [[ $PUSH_CHANGES -eq 1 ]]; then
    log "Pushing wikio branch to live wiki master"
    git -C "$TARGET_DIR" push -u origin wikio:master >/dev/null
  else
    log "Skipping push because --no-push was supplied"
  fi
}

main() {
  parse_args "$@"
  require_cmds git rsync
  [[ -f "$ROOT_DIR/sfdx-project.json" ]] || die "Run this script inside the EOEX-DUNEX repository"
  [[ -d "$SOURCE_DIR" ]] || die "Missing wiki source directory: $SOURCE_DIR"

  WIKI_URL="${WIKI_URL:-$(derive_wiki_url)}"
  ensure_clone
  ensure_git_identity
  prepare_branch

  if [[ "$MODE" == "status" ]]; then
    print_status
    return 0
  fi

  if [[ "$MODE" == "pull-only" ]]; then
    log "Pull-only mode completed"
    return 0
  fi

  sync_content
  ensure_local_readme

  if commit_if_needed; then
    push_if_requested
  fi

  log "wikio refresh completed"
}

main "$@"