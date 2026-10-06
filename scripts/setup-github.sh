#!/usr/bin/env bash
# Applies the repository-level settings described in docs/git-strategy.md.
# Requires: GitHub CLI (gh), authenticated as a repo admin (gh auth login).
# Usage: ./scripts/setup-github.sh [owner/repo]   (defaults to current repo)
# Safe to re-run: it updates the ruleset if it already exists.
set -euo pipefail

REPO="${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}"
RULESET=".github/rulesets/protect-main.json"
echo "Configuring $REPO ..."

# 1. Merge settings: squash only, auto-delete merged branches, allow auto-merge.
gh api -X PATCH "repos/$REPO" \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true \
  -F allow_auto_merge=true \
  -F allow_update_branch=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY >/dev/null
echo "  merge settings applied"

# 2. Branch ruleset protecting main.
id=$(gh api "repos/$REPO/rulesets" --jq '.[] | select(.name=="protect-main") | .id' || true)
if [ -n "$id" ]; then
  gh api -X PUT "repos/$REPO/rulesets/$id" --input "$RULESET" >/dev/null
  echo "  ruleset protect-main updated (id $id)"
else
  gh api -X POST "repos/$REPO/rulesets" --input "$RULESET" >/dev/null
  echo "  ruleset protect-main created"
fi

# 3. Label used by the emergency-fix path.
gh label create hotfix --repo "$REPO" --color B60205 \
  --description "Emergency fix: expedited review" --force >/dev/null
echo "  'hotfix' label ready"

echo "Done. Verify with: gh api repos/$REPO/rulesets"
