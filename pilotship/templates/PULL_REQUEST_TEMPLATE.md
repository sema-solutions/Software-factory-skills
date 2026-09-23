<!-- factory-template-version: 1.1 -->
## Why

<!-- What problem does this solve? Why now? Link the issue or task. -->

## What changes

<!-- Bulleted list of files / behaviors changed. Call out anything touching
     shared modules, auth, schema, or per-client code. -->

## Proof

<!-- Required. Pick one:
     - Visible change: a Before | After table (before-and-after --markdown,
       uploaded via the gist adapter).
     - Non-visible change: measured numbers or output pairs (before → after).
     - Carve-out: "docs-only" / "dependency bump" / "CI config".
     State the exact commit and environment the evidence was captured on. -->

| Before | After |
|---|---|
|  |  |

Tested on commit `<sha>` in `<environment>`.

## Test plan

- [ ] Repo checks pass locally (paste the command and its tail)
- [ ] CI green
- [ ] <specific behavior> verified on <specific page / endpoint>
- [ ] (If touching DB) migration applied on a fresh worktree database
- [ ] (If touching auth) signed in fresh and verified session works

## Review loop

<!-- Filled by greploop. Repos without a review bot write an explicit waiver instead,
     e.g. "waived: no bot on this repo" — the merge log treats anything else as skipped. -->
Reviewer: <Greptile / PR-Agent> · Iterations: <n> · Final: <5/5, 0 unresolved>

## Risks and follow-ups

<!-- What could go wrong, what is deliberately out of scope, what comes next. -->
