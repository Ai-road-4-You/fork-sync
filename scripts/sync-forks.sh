#!/usr/bin/env bash
set -euo pipefail

# Sync all managed forks with their upstream repositories
# Implements 7-level classification per fork-governance.md
# Usage: ./scripts/sync-forks.sh [--dry-run]

DRY_RUN="${1:-}"
DIVERGENCE_COMMIT_THRESHOLD=100
DIVERGENCE_FILE_THRESHOLD=50

echo "=== iAiFy Fork Sync ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Mode: ${DRY_RUN:-live}"
echo ""

TOTAL=0
SYNCED=0
SKIPPED=0
ISSUES_CREATED=0

classify_and_sync() {
  local fork="$1"
  local upstream
  upstream=$(gh api "/repos/$fork" --jq '.parent.full_name // "none"' 2>/dev/null)

  if [ "$upstream" = "none" ]; then
    echo "SKIP $fork (no upstream)"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  TOTAL=$((TOTAL + 1))

  # Get comparison data
  local compare_json
  compare_json=$(gh api "/repos/$fork/compare/main...main" 2>/dev/null || echo '{}')
  local behind
  behind=$(echo "$compare_json" | jq -r '.behind_by // 0')
  local files_changed
  files_changed=$(echo "$compare_json" | jq -r '.files | length // 0' 2>/dev/null || echo "0")

  if [ "$behind" -eq 0 ]; then
    echo "UP-TO-DATE $fork"
    SYNCED=$((SYNCED + 1))
    return
  fi

  # Classification logic (per fork-governance.md)
  local classification="unknown"

  # Check for divergence-too-high
  if [ "$behind" -gt "$DIVERGENCE_COMMIT_THRESHOLD" ] || [ "$files_changed" -gt "$DIVERGENCE_FILE_THRESHOLD" ]; then
    classification="divergence-too-high"
  else
    # Try merge-upstream API (dry run equivalent: check if merge is possible)
    local merge_result
    if [ "$DRY_RUN" = "--dry-run" ]; then
      # In dry run, just check the comparison
      local ahead
      ahead=$(echo "$compare_json" | jq -r '.ahead_by // 0')
      if [ "$ahead" -eq 0 ]; then
        classification="clean-fast-forward"
      else
        classification="merge-safe"  # Assume safe in dry-run, actual merge will confirm
      fi
    else
      merge_result=$(gh api "/repos/$fork/merge-upstream" --method POST -f branch=main 2>&1) || true
      if echo "$merge_result" | grep -q '"merge_type":"fast-forward"'; then
        classification="clean-fast-forward"
        SYNCED=$((SYNCED + 1))
      elif echo "$merge_result" | grep -q '"merge_type":"merge"'; then
        classification="merge-safe"
        SYNCED=$((SYNCED + 1))
      elif echo "$merge_result" | grep -q "conflict"; then
        classification="conflict-detected"
      else
        classification="manual-review-required"
      fi
    fi
  fi

  echo "$classification $fork ($behind commits behind, $files_changed files) upstream=$upstream"

  # Create issues for non-auto-resolvable cases
  if [ "$DRY_RUN" != "--dry-run" ]; then
    case "$classification" in
      conflict-detected|divergence-too-high|manual-review-required)
        gh issue create --repo "$fork" \
          --title "Fork sync: $classification" \
          --body "Upstream: $upstream\nCommits behind: $behind\nFiles changed: $files_changed\nClassification: $classification\n\nRequires manual intervention per fork-governance.md." \
          --label "fork-sync-failure" 2>/dev/null || true
        ISSUES_CREATED=$((ISSUES_CREATED + 1))
        ;;
    esac
  fi
}

for org in AiFeatures AiProducting; do
  echo ""
  echo "--- Organization: $org ---"
  forks=$(gh api "/orgs/$org/repos?type=forks&per_page=100" --jq '.[].full_name' 2>/dev/null || echo "")
  for fork in $forks; do
    classify_and_sync "$fork"
  done
done

echo ""
echo "=== Sync Summary ==="
echo "Total forks processed: $TOTAL"
echo "Synced successfully: $SYNCED"
echo "Skipped: $SKIPPED"
echo "Issues created: $ISSUES_CREATED"
echo "=== Complete ==="
