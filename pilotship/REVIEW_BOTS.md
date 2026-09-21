# Review bots: decision record

The Ship beat needs a reviewer the agent can loop against until the work is
clean. This records what we picked, why, and what it takes to swap.

## Decision (2026-09-21)

- **Pilot on Greptile, Starter tier.** Free for one developer, 50 review
  credits a month, unlimited repos. The `greploop` skill works unchanged
  because Greptile emits a numeric confidence score and resolvable review
  threads.
- **Run PR-Agent in parallel on the same pilot PRs**, pointed at our own
  model key. It is MIT-licensed and costs only tokens. After 10 to 15 PRs we
  will have side-by-side data on our own code instead of vendor benchmarks.
  If it holds up, it becomes the zero-seat-cost default for Phase 3 and
  Greptile stays where precision matters most.
- **Pro tier ($30/seat/month) when a second developer starts authoring PRs.**
  A seat is a developer who received a review that month, not a repo. Agents
  pushing under a developer's GitHub account share that developer's seat;
  never give agents their own bot account or it becomes a paid seat.

## What the evidence said

The only independent hands-on test found ran four bots on 146 real PRs for
three and a half weeks and hand-verified 679 findings (author works at
Sentry, which makes one of the four, and disclosed it):

| Tool | Findings | Verified false positives | Price |
|---|---|---|---|
| Greptile | 120 | 0% | $30/seat, free Starter |
| CodeRabbit | 281 | 2.3% | $24/user |
| Cursor BugBot | 128 | 4.8% | $40/user |
| Sentry Seer | 120 | 15% at "high" | $40/active contributor |

Vendor benchmarks from Macroscope and CodePulse rank Greptile low on recall
and precision respectively; both sell a competing reviewer and both put
themselves first. Greptile's own benchmark has the mirror-image problem.
Greptile and CodeRabbit are the two with the most independent human
validation. Either is defensible.

Open source: **PR-Agent** (MIT, ~13k stars, community-maintained since Qodo
handed it over in April 2026, any model via LiteLLM, GitHub Action deploy) is
the real contender. **Kodus** (AGPL, self-hosted, needs Postgres + Mongo +
RabbitMQ) is worth watching, not adopting. Rule-based tools (SonarQube,
Semgrep, CodeQL) complement rather than replace an AI reviewer.

Sources are linked in the research summary of 2026-09-21 in the Pilotship
session notes.

## Swapping the bot: what greploop needs

`greploop` exits when **confidence is 5/5 and zero threads are unresolved**.
Only Greptile emits the score. For any other bot the exit condition becomes
**a fresh review on the current head produced zero unresolved actionable
comments**. That is a small edit to the skill's step C, not a redesign:

1. Trigger: replace `@greptile review` with the bot's trigger (`/review` for
   PR-Agent, `@codex review` for Codex, automatic for BugBot).
2. Fetch: read the bot's latest review comment on the current head SHA.
3. Exit: zero unresolved actionable comments → done. Otherwise fix, resolve,
   push, repeat, up to `--max-iterations`.

If PR-Agent wins the pilot, we vendor a `prloop` variant of the skill with
those three changes rather than editing `greploop` in place, so the upstream
sync stays clean.

## Setup notes

**Greptile:** install the GitHub App on the `Pilotship-io` org scoped to the
pilot repo only. Confirm on a throwaway PR that a review comment appears and
that `gh pr checks` lists a check run whose name contains `greptile`;
`greploop` polls that check run. Private-repo coverage is standard for a
GitHub App install; confirm it during the trial.

**PR-Agent:** copy `templates/github/pr-agent.yml` into
`.github/workflows/`, add the model key as a repo secret, verify the env
variable names against the current PR-Agent docs before enabling. It reviews
on PR open and on `/review` comments.
