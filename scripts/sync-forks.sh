#!/usr/bin/env bash
set -euo pipefail

# Sync all managed forks with their upstream repositories
# Usage: ./scripts/sync-forks.sh [--dry-run]

DRY_RUN="${1:-}"

echo "=== iAiFy Fork Sync ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Get all forks
for org in AiFeatures AiProducting; do
  echo ""
  echo "--- Organization: $org ---"

  forks=$(GITHUB_TOKEN= gh api "/orgs/$org/repos?type=forks&per_page=100" --jq '.[].full_name')

  for fork in $forks; do
    upstream=$(GITHUB_TOKEN= gh api "/repos/$fork" --jq '.parent.full_name // "none"')

    if [ "$upstream" = "none" ]; then
      echo "SKIP $fork (no upstream found)"
      continue
    fi

    # Check if fork is behind upstream
    compare=$(GITHUB_TOKEN= gh api "/repos/$fork/compare/main...main" 2>/dev/null || echo '{"behind_by":0}')
    behind=$(echo "$compare" | jq -r '.behind_by // 0')

    if [ "$behind" -gt 0 ]; then
      echo "BEHIND $fork ($behind commits behind $upstream)"
      if [ "$DRY_RUN" != "--dry-run" ]; then
        GITHUB_TOKEN= gh api "/repos/$fork/merge-upstream" --method POST -f branch=main || echo "  WARN: Could not auto-sync $fork"
      fi
    else
      echo "OK $fork (up to date with $upstream)"
    fi
  done
done

echo ""
echo "=== Sync complete ==="
