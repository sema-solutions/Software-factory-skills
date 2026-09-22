#!/usr/bin/env bash
# merge-log.sh — turn a merged PR into a MERGE_LOG.md row, a job summary, and
# a factory verdict. Used by .github/workflows/merge-log.yml; runnable locally:
#
#   gh pr view 2 --json number,title,author,mergedAt,url,body > pr.json
#   bash pilotship/scripts/merge-log.sh pr.json pilotship/MERGE_LOG.md
#
# Verdict rules (a PR "went through the factory" when both hold):
#   1. a "## Proof" section exists and has content other than the template
#      placeholders (a carve-out sentence counts: "docs-only" etc.)
#   2. the "## Review loop" section reports 5/5, or an explicit waiver:
#      "waived" / "no bot" (with a reason) — the fork itself has no review bot.
# Exit code: 0 = factory ok, 3 = factory skipped (the row is still written).
set -euo pipefail
pr_json="$1"; log_file="$2"

number=$(jq -r '.number' "$pr_json")
title=$(jq -r '.title' "$pr_json")
author=$(jq -r '.author.login // .user.login // "?"' "$pr_json")
merged_at=$(jq -r '.mergedAt // .merged_at // ""' "$pr_json" | cut -c1-10)
url=$(jq -r '.url // .html_url' "$pr_json")
body=$(jq -r '.body // ""' "$pr_json")

section() { # section <heading-regex> -> text until the next "## "
  printf '%s\n' "$body" | awk -v h="$1" '
    $0 ~ "^## " { inside = ($0 ~ h) ? 1 : 0; next }
    inside { print }'
}
strip_placeholders() { sed -E '/^<!--/,/-->/d; /^\|[- |]*\|$/d; /^\| *\| *\|$/d; /^\|? *Before *\|? *After *\|?$/d; /^\s*$/d; /Tested on commit `<sha>`/d'; }

proof="$(section '^## Proof' | strip_placeholders || true)"
review="$(section '^## Review loop' || true)"

proof_ok=no;  [ -n "$proof" ] && proof_ok=yes
review_ok=no
if printf '%s' "$review" | grep -qE '5/5'; then review_ok=yes
elif printf '%s' "$review" | grep -qiE 'waived|no bot'; then review_ok=waived; fi

if [ "$proof_ok" = yes ] && [ "$review_ok" != no ]; then verdict="ok"; else verdict="skipped"; fi
review_short="$( { printf '%s' "$review" | grep -oE '5/5[^|]*|[Ww]aived[^|]*|[Nn]o bot[^|]*' || true; } | head -1 | cut -c1-60 | tr -d '\n')"
[ -n "$review_short" ] || review_short="none"

row="| $merged_at | [#$number]($url) | $(printf '%s' "$title" | sed 's/|/\\|/g') | $author | proof: $proof_ok | review: $review_short | **$verdict** |"

# append row (create the log with a header if missing)
if [ ! -f "$log_file" ]; then
  cat > "$log_file" <<'HDR'
# Merge log

Every PR merged into this repo, appended automatically by
`.github/workflows/merge-log.yml`. **ok** = the PR carried a Proof section and
a 5/5 review (or an explicit waiver). **skipped** = it did not; the Actions run
for that merge is red so the gap is visible.

| Merged | PR | Title | Author | Proof | Review loop | Factory |
|---|---|---|---|---|---|---|
HDR
fi
grep -qF "[#$number]($url)" "$log_file" || printf '%s\n' "$row" >> "$log_file"

# job summary (GitHub shows GITHUB_STEP_SUMMARY on the run page)
{
  echo "## Merge: #$number $title"
  echo
  echo "| Field | Value |"; echo "|---|---|"
  echo "| Repo | $(jq -r '.baseRepository.nameWithOwner // .base.repo.full_name // "-"' "$pr_json") |"
  echo "| Author | $author |"; echo "| Merged | $merged_at |"
  echo "| Proof section | $proof_ok |"; echo "| Review loop | $review_short |"
  echo "| Factory verdict | **$verdict** |"
  echo "| Link | $url |"
  if [ "$verdict" = skipped ]; then
    echo; echo "> This PR skipped the factory: $( [ "$proof_ok" = no ] && printf 'no Proof section. ' )$( [ "$review_ok" = no ] && printf 'no 5/5 review result or waiver in the Review loop section.' )"
  fi
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "merge-log: #$number verdict=$verdict proof=$proof_ok review=$review_short"
[ "$verdict" = ok ] || exit 3
