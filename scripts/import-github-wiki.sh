#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$ROOT_DIR/tmp"
SOURCE_DIR="$ROOT_DIR/wiki"
COMMIT_MESSAGE="docs(wiki): import project wiki"
KEEP_CLONE=0
PUSH_CHANGES=1
WIKI_URL=""
WORK_DIR=""

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: bash scripts/import-github-wiki.sh [options]

Options:
  --wiki-url <url>         Override the derived GitHub Wiki remote URL
  --commit-message <text>  Commit message to use in the wiki repository
  --no-push                Sync and commit locally, but do not push
  --keep-clone             Keep the temporary cloned wiki directory
  --help                   Show this help text
EOF
}

require_cmds() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "Required command not found: $cmd"
  done
}

cleanup() {
  if [[ $KEEP_CLONE -eq 0 && -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
    rm -rf "$WORK_DIR"
  fi
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

  git -C "$WORK_DIR" config user.name "$name"
  git -C "$WORK_DIR" config user.email "$email"
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
      --keep-clone)
        KEEP_CLONE=1
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

main() {
  parse_args "$@"
  require_cmds git rsync mktemp
  [[ -f "$ROOT_DIR/sfdx-project.json" ]] || die "Run this script inside the EOEX-DUNEX repository"
  [[ -d "$SOURCE_DIR" ]] || die "Missing wiki source directory: $SOURCE_DIR"

  mkdir -p "$TMP_DIR"
  WIKI_URL="${WIKI_URL:-$(derive_wiki_url)}"
  WORK_DIR="$(mktemp -d "$TMP_DIR/github-wiki.XXXXXX")"
  trap cleanup EXIT

  log "Cloning wiki repository: $WIKI_URL"
  git clone "$WIKI_URL" "$WORK_DIR" >/dev/null 2>&1 || die "Unable to clone wiki repository. Confirm the GitHub Wiki is enabled and you have access."

  ensure_git_identity

  log "Syncing local wiki content into temporary clone"
  rsync -a --delete --exclude '.git/' "$SOURCE_DIR/" "$WORK_DIR/"

  if git -C "$WORK_DIR" diff --quiet && git -C "$WORK_DIR" diff --cached --quiet; then
    log "No wiki changes detected"
    if [[ $KEEP_CLONE -eq 1 ]]; then
      log "Temporary clone retained at $WORK_DIR"
      trap - EXIT
    fi
    return 0
  fi

  git -C "$WORK_DIR" add --all

  if git -C "$WORK_DIR" diff --cached --quiet; then
    log "No staged wiki changes after sync"
    if [[ $KEEP_CLONE -eq 1 ]]; then
      log "Temporary clone retained at $WORK_DIR"
      trap - EXIT
    fi
    return 0
  fi

  log "Creating wiki commit"
  git -C "$WORK_DIR" commit -m "$COMMIT_MESSAGE" >/dev/null

  if [[ $PUSH_CHANGES -eq 1 ]]; then
    log "Pushing wiki update"
    git -C "$WORK_DIR" push origin HEAD >/dev/null
  else
    log "Skipping push because --no-push was supplied"
  fi

  if [[ $KEEP_CLONE -eq 1 ]]; then
    log "Temporary clone retained at $WORK_DIR"
    trap - EXIT
  fi

  log "Wiki import completed"
}

main "$@"