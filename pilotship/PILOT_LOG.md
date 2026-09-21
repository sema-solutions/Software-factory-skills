# Pilot log

What broke, what got changed, how long each beat took. One row per PR that
went through the factory during the pilot. Fold the lessons into the
templates and skills before tagging v1.0.

Pilot repo: `Pilotship-io/pilotship-web` · Started: 2026-09-21

## PRs

| Date | Repo / PR | Harness | Model | Isolate | Build | Prove | Ship (loops to 5/5) | What broke | Fix applied where |
|---|---|---|---|---|---|---|---|---|---|
| | | | | | | | | | |

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
| 2026-09-21 | `pilotship/*` | Initial Pilotship layer | Phase 0 |
| 2026-09-21 | `templates/scripts/worktree-env.sh` | `DB_BOOTSTRAP_SQL` hook + `psql_db` helper | Finding 1 and 2 above |

## Open questions to settle before v1.0

- [ ] greploop iteration cap: keep 10 or lower it?
- [ ] Greptile auto-review on PR open, or only on `@greptile review`? (credits)
- [ ] Which PR types are exempt from proof? (docs-only, dependency bumps, CI config so far)
- [ ] Does Cursor auto-load the skills, or does it need an explicit mention?
- [ ] Does Codex CLI auto-load the skills, or does it need an explicit mention?
- [ ] PR-Agent side-by-side: keep, drop, or make it the default for Phase 3?
