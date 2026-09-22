# Rollout checklist: one repo

Copy this into the rollout PR description for each repo. Budget about an hour
per repo once the pilot has been dialed in.

**Repo:** ______________  **Date:** ______________  **Driver:** ______________

## Install

- [ ] Clone the factory repo (or `git pull` it) and run `bash <factory>/pilotship/factory-init.sh` from the repo root on a new branch `chore/software-factory`
- [ ] Skills present: `ls .agents/skills` shows all seven; `.claude/skills/*` symlinks resolve
- [ ] `skills-lock.json` committed
- [ ] `.gitignore` has the factory block

## Contract

- [ ] `AGENTS.md`: four beats, multi-agent rules, house rules intact (merge into the existing file if there was one; the old content becomes the repo-specific section)
- [ ] Repo-specific section filled: project at a glance, setup, commands and checks, hard invariants, environment, shared local resources, what can't be tested locally
- [ ] `bash <factory>/pilotship/scripts/check-contract.sh AGENTS.md` passes: the shared sections are verbatim, every repo note sits below the REPO-SPECIFIC marker (the reviewer enforces the header's "keep intact" rule literally; pilotship-web #217 lost a round to it)
- [ ] `CLAUDE.md` is a thin pointer (existing Claude-specific notes kept)
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` in place with the Proof section
- [ ] Any `*.factory.*` leftovers merged and deleted

## Machine readiness

- [ ] `scripts/doctor.sh` settings block filled (Node major, DB_CONTAINER if the repo has a local database, env file)
- [ ] `npm run doctor` (or the task runner's equivalent) wired; `AGENTS.md` → Setup and `CONTRIBUTING.md` point at it
- [ ] Doctor run on a machine that has never run this repo: every ✗ has a fix command that works
- [ ] Windows developers on the repo use WSL2 (the doctor refuses a native Windows shell); no package.json script relies on shell syntax that cmd.exe cannot expand (e.g. `${PORT:-3000}`; wrap it in a small node script instead)

## Isolation (repos with a local database)

- [ ] `scripts/worktree-env.sh` settings block filled (DB_PREFIX, DB_CONTAINER, user/password, port base); `scripts/worktree-id.sh` copied alongside (both scripts source it)
- [ ] `scripts/db-guard.sh` DB_PREFIX matches
- [ ] Compose file has a fixed `name:` (so every worktree targets one container) and an overridable host port (`${PGPORT_HOST:-5432}`) for machines where 5432 is taken
- [ ] If migrations cannot run from scratch with the plain generator (role switches, extensions), a local runner + bootstrap SQL like pilotship-web's `scripts/migrate-local.ts` / `db-bootstrap-local.sql`
- [ ] `db-guard` wired in front of migrate, seed, reset in `package.json` (or the equivalent task runner)
- [ ] Dev script honors `$PORT`
- [ ] `db:reset` no longer stops or recreates the shared container; it drops and recreates only the current database
- [ ] Harness permissions: `db:down`, `docker compose down`, `docker volume rm`, `db:push` on the ask list (Claude Code `.claude/settings.json`); other harnesses rely on the script guard
- [ ] Proven: two worktrees side by side, each with its own database and port, one runs `db:reset`, the other's data survives

## Review bot

- [ ] Greptile (or the chosen bot) installed on this repo
- [ ] A throwaway PR gets a review comment and a check run named `greptile` appears in `gh pr checks`
- [ ] Seats: confirm which developers will author PRs here (seat = developer, not repo)

## Proof of the loop

- [ ] The rollout PR itself went through all four beats: worktree, checks, proof in the body, greploop to 5/5
- [ ] One real feature shipped through the factory in this repo
- [ ] Anything that broke logged in `PILOT_LOG.md`

## Team

- [ ] Every developer on this repo has done the machine setup in `ONBOARDING.md` and read `PATTERNS.md`
- [ ] Date announced after which every PR carries proof and a 5/5 or an explicit waiver
