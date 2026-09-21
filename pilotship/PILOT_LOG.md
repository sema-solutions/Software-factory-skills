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

## Skill and template edits made during the pilot

| Date | File | Change | Why |
|---|---|---|---|
| 2026-09-21 | `pilotship/*` | Initial Pilotship layer | Phase 0 |

## Open questions to settle before v1.0

- [ ] greploop iteration cap: keep 10 or lower it?
- [ ] Greptile auto-review on PR open, or only on `@greptile review`? (credits)
- [ ] Which PR types are exempt from proof? (docs-only, dependency bumps, CI config so far)
- [ ] Does Cursor auto-load the skills, or does it need an explicit mention?
- [ ] Does Codex CLI auto-load the skills, or does it need an explicit mention?
- [ ] PR-Agent side-by-side: keep, drop, or make it the default for Phase 3?
