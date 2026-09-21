# CLAUDE.md

Claude Code specific notes. **The universal contract is [`AGENTS.md`](./AGENTS.md).**
Read that first; everything in it applies here. This file only covers what
differs in Claude Code.

## Skills

Factory skills live in `.agents/skills/` and are symlinked into
`.claude/skills/`, so Claude Code loads them on demand like any project skill:
`new-feature`, `code-structure`, `evidence-driven-testing`, `before-and-after`,
`greploop`, `greploop-apps`, `unslop`. Repo-specific skills sit alongside them.

## Worktrees

Claude Code creates and manages worktrees itself under `.claude/worktrees/`.
Per the `new-feature` skill, skip the manual `git worktree add` steps and keep
the harness-assigned branch name. Still run `scripts/worktree-env.sh` (if the
repo has it) as the first command in a fresh worktree.

## Permissions

`.claude/settings.json` denies pushes to `main`, force pushes, and destructive
SQL, and asks before anything that stops or wipes the shared database
container (`db:down`, `docker compose down`, `db:push`). These mirror the
rules in AGENTS.md; the script guards in `scripts/` enforce the same rules in
every other harness.

## Plan mode

For any non-trivial change (new feature, refactor, anything touching a
kernel or shared module), plan first, get approval, then build. Trivial fixes
can proceed directly.

## What NOT to do (Claude-specific additions)

- Don't merge PRs. Hand the URL to a human.
- Don't run cloud IAM, secret, or database-instance mutations without explicit
  approval. Read-only operations are fine.
