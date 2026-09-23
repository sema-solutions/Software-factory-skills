#!/usr/bin/env bash
# check-contract.sh — is a repo's AGENTS.md still carrying the shared contract
# verbatim? The sections between "## Start here" and the REPO-SPECIFIC
# marker are the part every factory repo must share; repo-specific text goes
# below the marker. The reviewer enforces the header's "keep intact" rule
# literally, so run this before opening a PR that touches AGENTS.md.
#
#   bash <factory>/pilotship/scripts/check-contract.sh [path/to/AGENTS.md]
# Exit 0 = identical to the template; 1 = differs (diff printed); 2 = usage.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
tpl="$here/../AGENTS.template.md"
target="${1:-AGENTS.md}"
[ -f "$target" ] || { echo "check-contract: $target not found" >&2; exit 2; }
extract() { awk '/^## Start here/{f=1} /^<!-- =+ REPO-SPECIFIC/{f=0} f' "$1"; }
tv="$( { grep -hoE 'factory-template-version: [0-9.]+' "$tpl" || true; } | head -1 | awk '{print $2}')"
rv="$( { grep -hoE 'factory-template-version: [0-9.]+' "$target" || true; } | head -1 | awk '{print $2}')"
[ "$rv" = "$tv" ] || echo "check-contract: $target is on template v${rv:-none}, template is v$tv (re-run factory-init.sh and merge)"
if diff -u <(extract "$tpl") <(extract "$target") > /tmp/check-contract.diff; then
  echo "check-contract: shared sections of $target match template v$tv"
  exit 0
fi
echo "check-contract: shared sections of $target differ from template v$tv. Move repo-specific text below the REPO-SPECIFIC marker, or update the template if the change is meant for every repo."
cat /tmp/check-contract.diff
exit 1
