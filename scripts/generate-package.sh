#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/common.sh
source "$SCRIPT_DIR/common.sh"

require_cmds git awk sed sort uniq tr
require_repo_root

cd "$ROOT_DIR"

story_id="${1:-}"
[[ -n "$story_id" ]] || die "Usage: $0 US-XXX"

story_dir="$ROOT_DIR/manifest/user-stories/$story_id"
story_file="$story_dir/story.txt"
hints_file="$story_dir/metadata-hints.txt"
analysis_file="$story_dir/metadata-analysis.txt"
package_file="$story_dir/package.xml"
matches_file="$TMP_DIR/${story_id}.metadata.txt"

[[ -f "$story_file" ]] || die "Missing user-story text: $story_file"

story_text_lc="$(tr '[:upper:]' '[:lower:]' < "$story_file")"
mkdir -p "$story_dir"
: > "$matches_file"

while IFS= read -r metadata_path; do
  [[ -n "$metadata_path" ]] || continue
  ref="$(metadata_ref_from_path "$metadata_path" 2>/dev/null || true)"
  [[ -n "$ref" ]] || continue
  member_lc="$(printf '%s' "${ref#*:}" | tr '[:upper:]' '[:lower:]')"
  if [[ "$story_text_lc" == *"$member_lc"* ]]; then
    printf '%s\n' "$ref" >> "$matches_file"
  fi
done < <(find force-app/main/default -type f | sort)

if [[ -f "$hints_file" ]]; then
  awk 'NF && $1 !~ /^#/' "$hints_file" >> "$matches_file"
fi

if [[ -f "$ROOT_DIR/config/metadata-dependencies.csv" ]]; then
  changed=1
  while [[ "$changed" -eq 1 ]]; do
    changed=0
    while IFS=',' read -r source target; do
      [[ "$source" == "source" ]] && continue
      if grep -qxF "$source" "$matches_file" && ! grep -qxF "$target" "$matches_file"; then
        printf '%s\n' "$target" >> "$matches_file"
        changed=1
      fi
    done < "$ROOT_DIR/config/metadata-dependencies.csv"
  done
fi

sort -u "$matches_file" -o "$matches_file"
[[ -s "$matches_file" ]] || die "No metadata could be inferred for $story_id. Add metadata-hints.txt and retry."

{
  printf 'User story: %s\n' "$story_id"
  printf 'Generated: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  printf 'Selected metadata:\n'
  sed 's/^/- /' "$matches_file"
} > "$analysis_file"

{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<Package xmlns="http://soap.sforce.com/2006/04/metadata">\n'
  awk -F':' '
    {
      items[$1] = items[$1] $2 "\n"
    }
    END {
      for (type in items) {
        printf "TYPE\t%s\n%s", type, items[type]
      }
    }
  ' "$matches_file" | awk '
    /^TYPE\t/ {
      if (current_type != "") {
        printf "    <name>%s</name>\n", current_type
        printf "</types>\n"
      }
      current_type = substr($0, 6)
      printf "    <types>\n"
      next
    }
    NF {
      printf "        <members>%s</members>\n", $0
    }
    END {
      if (current_type != "") {
        printf "    <name>%s</name>\n", current_type
        printf "    </types>\n"
      }
    }
  '
  printf '    <version>62.0</version>\n'
  printf '</Package>\n'
} > "$package_file"

log "Generated $package_file"
log "Generated $analysis_file"
