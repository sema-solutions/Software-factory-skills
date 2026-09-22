#!/usr/bin/env bash
# factory-template-version: 1.0  (keep: factory-init.sh compares it on re-runs)
# worktree-id.sh — ONE definition of a worktree's identity, sourced by
# scripts/worktree-env.sh and scripts/db-guard.sh so they can never disagree.
#
# worktree_id <branch>  ->  <readable prefix>_<8 hex of sha256(full branch)>
#
# The hash is over the FULL branch name, so branches that differ only in
# punctuation ("lead-notes" vs "lead_notes") or beyond the readable prefix
# never map to the same database or port.
hash_hex() {
  if command -v shasum >/dev/null 2>&1; then printf '%s' "$1" | shasum -a 256 | cut -c1-8
  elif command -v sha256sum >/dev/null 2>&1; then printf '%s' "$1" | sha256sum | cut -c1-8
  else printf '%08x' "$(printf '%s' "$1" | cksum | cut -d' ' -f1)"; fi
}
worktree_id() {
  local b="$1" prefix
  prefix="$(printf '%s' "$b" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//' | cut -c1-30 | sed -E 's/_+$//')"
  printf '%s_%s' "$prefix" "$(hash_hex "$b")"
}
