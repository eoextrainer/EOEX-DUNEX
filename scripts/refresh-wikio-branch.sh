#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/wiki"
TARGET_DIR="$ROOT_DIR/tmp/wikio-branch"
COMMIT_MESSAGE="docs(wiki): refresh local wikio branch"
PUSH_CHANGES=1
WIKI_URL=""

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

sync_content() {
  log "Syncing repository wiki content into $TARGET_DIR"
  rsync -a --delete --exclude '.git/' "$SOURCE_DIR/" "$TARGET_DIR/"
}

commit_if_needed() {
  git -C "$TARGET_DIR" add --all

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
  sync_content

  if commit_if_needed; then
    push_if_requested
  fi

  log "wikio refresh completed"
}

main "$@"