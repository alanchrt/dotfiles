#!/usr/bin/env bash
# Scans all stream clones under ~/Projects/<project>/<branch>/ for in-flight work
# (uncommitted, unpushed) and open PRs. Sends a desktop notification summary.
# Intended to run via systemd timer, not as a Claude hook.

set -euo pipefail

PROJECTS_DIR="$HOME/Projects"
INFLIGHT=()

for project_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$project_dir" ]] || continue
  project_name=$(basename "$project_dir")

  for stream_dir in "$project_dir"*/; do
    [[ -d "$stream_dir/.git" ]] || continue
    stream_slug=$(basename "$stream_dir")
    # Skip the canonical
    [[ "$stream_slug" == "main" ]] && continue

    current_branch=$(git -C "$stream_dir" branch --show-current 2>/dev/null || true)
    [[ -z "$current_branch" ]] && continue

    # Unpushed commits
    if git -C "$stream_dir" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
      unpushed=$(git -C "$stream_dir" log --oneline '@{upstream}..HEAD' 2>/dev/null | wc -l)
    else
      unpushed=$(git -C "$stream_dir" log --oneline 2>/dev/null | wc -l)
    fi
    if [[ "$unpushed" -gt 0 ]]; then
      INFLIGHT+=("$current_branch — $unpushed unpushed ($project_name)")
    fi

    # Open PRs authored by me, scoped to this stream's checkout
    if command -v gh &>/dev/null; then
      while IFS=$'\t' read -r pr_number pr_title; do
        [[ -z "$pr_number" ]] && continue
        INFLIGHT+=("#$pr_number: $pr_title ($project_name)")
      done < <(gh -R "$(git -C "$stream_dir" remote get-url origin 2>/dev/null)" \
                  pr list --author "@me" --head "$current_branch" \
                  --json number,title --jq '.[] | [.number, .title] | @tsv' 2>/dev/null || true)
    fi
  done
done

if [[ ${#INFLIGHT[@]} -eq 0 ]]; then
  exit 0
fi

SUMMARY="You have ${#INFLIGHT[@]} pieces of in-flight work:"
BODY=""
for item in "${INFLIGHT[@]}"; do
  BODY+="• $item\n"
done

notify-send -i dialog-information "Claude Code — In-Flight Work" "$SUMMARY\n$BODY" 2>/dev/null || true
