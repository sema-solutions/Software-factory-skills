# Pilot log

What broke, what got changed, how long each beat took. One row per PR that
went through the factory during the pilot. Fold the lessons into the
templates and skills before tagging v1.0.

Pilot repo: `Pilotship-io/pilotship-web` · Started: 2026-09-21

## PRs

| Date | Repo / PR | Harness | Model | Isolate | Build | Prove | Ship (loops to 5/5) | What broke | Fix applied where |
|---|---|---|---|---|---|---|---|---|---|
| 2026-09-21 | pilotship-web #206 (throwaway, closed) | Claude Code | Fable 5.1 | 1 | 1 | n/a (docs carve-out) | 2 reviews, 4/5 → 5/5 | Nothing. Verified Greptile install: summary comment with `Confidence Score: N/5` in ~100s, check run named `Greptile Review`, `@greptile review` re-triggers in ~2 min. Greptile EDITS its summary comment (watch `updated_at`) and re-uses the check run (count stays 1). Both already handled by greploop. | Greptile settings: retrigger-on-push OFF, update-PR-description OFF, Prompt-to-Fix ON, sequence diagrams OFF |
| 2026-09-21 | pilotship-web #207 (chore/software-factory-a1c7) | Claude Code | Fable 5.1 | 5 | 120 | 40 | 3 loops, 2/5 → 2/5 → 5/5 (~35 min) | Five setup findings (list below) + six Greptile findings across two rounds, all real, all fixed: slug collision, weak SET ROLE handling, quoted URL, public uploads (default host, then public gists), port collision | pilotship-web scripts + fork template (PR #2) |

Time columns are wall-clock minutes for the beat, roughly. "What broke"
means anything a human had to step in for: a skipped beat, a guard that
fired wrongly, a tool that was missing, a screenshot that leaked data.

## What broke during the pilotship-web rollout (2026-09-21)

1. **Fresh local databases could not be migrated at all** (pre-existing, unrelated to the factory). Migration 0010 ends with `SET ROLE pilotship_migrator`; on a from-scratch `drizzle-kit migrate` every later statement runs as that role while earlier tables belong to the superuser. Failed with "permission denied for schema drizzle", then "must be owner of table". Fix: `scripts/migrate-local.ts` runs every migration as the migrator (mirrors CI) and `scripts/db-bootstrap-local.sql` grants what a non-superuser migrator needs on a fresh database. Lesson for the template: a repo may need a bootstrap step between CREATE DATABASE and the first migration, hence `DB_BOOTSTRAP_SQL`.
2. **Bootstrap ran against the wrong database.** The admin psql helper connects to the `postgres` maintenance db; schema grants landed there. Fix: a `psql_db` helper bound to the new database. Ported to the template.
3. **Seed script could not resolve `server-only`.** The db module imports it; the package was never a dependency and only works under Node's `react-server` export condition. Fix: dev dependency plus `tsx --conditions=react-server`.
4. **Port 5432 was already taken** by another project's Postgres on this machine. Fix: `PGPORT_HOST` override in compose plus `name: pilotship-web` so every worktree targets the same container and volume.
5. **Symlinked `node_modules` in a second worktree crashes Turbopack** ("points out of the filesystem root"). Each worktree needs its own install, which is what `INSTALL_CMD` in `worktree-env.sh` does by default. Do not shortcut it.

Also learned: the primary checkout on this Mac had no `.env.local`, so the script's `.env.example` fallback got exercised for real and worked (the marketing site boots without secrets).

## Skill and template edits made during the pilot

| Date | File | Change | Why |
|---|---|---|---|
| 2026-09-21 | `templates/scripts/worktree-id.sh` (new), `worktree-env.sh`, `db-guard.sh`, `factory-init.sh` | collision-resistant worktree id (prefix + sha256 hash) shared by both scripts | Greptile finding on pilotship-web #207: truncated slugs could collide and defeat isolation |
| 2026-09-21 | `before-and-after/scripts/adapters/gist.sh` | secret gists instead of public | privacy of portal screenshots (Greptile round 2 on #207) |
| 2026-09-21 | `templates/scripts/worktree-env.sh` | collision-aware port allocation (skips sibling-claimed and listening ports, keeps own, fails when full) | Greptile round 2 on #207: hash % range could hand two worktrees the same port |
| 2026-09-21 | `before-and-after/scripts/upload-and-copy.sh` | default adapter 0x0st → gist | Greptile finding on pilotship-web #207: the vendored default contradicted AGENTS.md |
| 2026-09-21 | `pilotship/*` | Initial Pilotship layer | Phase 0 |
| 2026-09-21 | `templates/scripts/worktree-env.sh` | `DB_BOOTSTRAP_SQL` hook + `psql_db` helper | Finding 1 and 2 above |

## Open questions to settle before v1.0

- [ ] greploop iteration cap: keep 10 or lower it?
- [x] Greptile auto-review on PR open (ON), retrigger on push OFF; greploop re-triggers with `@greptile review` (verified 2026-09-21, ~2 min per loop, 1 credit each; #207 took 3 loops)
- [ ] Which PR types are exempt from proof? (docs-only, dependency bumps, CI config so far)
- [ ] Does Cursor auto-load the skills, or does it need an explicit mention?
- [ ] Does Codex CLI auto-load the skills, or does it need an explicit mention?
- [ ] PR-Agent side-by-side: keep, drop, or make it the default for Phase 3?
