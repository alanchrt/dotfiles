#!/usr/bin/env bash
# Scans all git repos under ~/Projects/ for in-flight worktree branches
# and unpushed work. Sends a desktop notification summary.
# Intended to run via systemd timer, not as a Claude hook.

set -euo pipefail

PROJECTS_DIR="$HOME/Projects"
INFLIGHT=()

for repo_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$repo_dir/.git" ]] || continue
  repo_name=$(basename "$repo_dir")

  # Check for worktree branches with unmerged work
  while IFS= read -r worktree_line; do
    wt_path=$(echo "$worktree_line" | awk '{print $1}')
    wt_branch=$(echo "$worktree_line" | sed 's/.*\[//;s/\]//')

    # Skip bare/detached
    [[ -z "$wt_branch" ]] && continue
    [[ "$wt_branch" == "(detached"* ]] && continue

    # Only report worktree- prefixed branches (created by Claude)
    if [[ "$wt_branch" == worktree-* ]]; then
      branch_display="${wt_branch#worktree-}"
      INFLIGHT+=("$branch_display ($repo_name)")
    fi
  done < <(git -C "$repo_dir" worktree list 2>/dev/null | tail -n +2)

  # Check for branches with unpushed commits
  current_branch=$(git -C "$repo_dir" branch --show-current 2>/dev/null || true)
  if [[ -n "$current_branch" && "$current_branch" != "main" && "$current_branch" != "master" ]]; then
    unpushed=$(git -C "$repo_dir" log --oneline "@{upstream}..HEAD" 2>/dev/null | wc -l || echo 0)
    if [[ "$unpushed" -gt 0 ]]; then
      INFLIGHT+=("$current_branch — $unpushed unpushed ($repo_name)")
    fi
  fi

  # Check for open PRs authored by me
  if command -v gh &>/dev/null; then
    while IFS=$'\t' read -r pr_number pr_title; do
      [[ -z "$pr_number" ]] && continue
      INFLIGHT+=("#$pr_number: $pr_title ($repo_name)")
    done < <(gh pr list --repo "$repo_dir" --author "@me" --json number,title --jq '.[] | [.number, .title] | @tsv' 2>/dev/null || true)
  fi
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
