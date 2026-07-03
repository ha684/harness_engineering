# QUALITY.md

<!--
  Per-module quality tracker (lecture 12).
  An ACTIVE artifact — not a one-time audit. Scores change over time.

  Scoring rubric:
    A — All verifications passing, agent-understandable, stable tests, follows conventions
    B — Mostly fine, minor known issues, occasional manual nudge needed
    C — Multiple issues: flaky tests, boundary violations, hard for new agent to grasp
    D — Critical issues: failing verification, severe architectural drift, needs urgent attention

  Rule of thumb:
    - New sessions should fix the lowest-scored module that affects their work BEFORE adding new features in that area.
    - A drop from B to C is a signal that technical debt is compounding. Schedule a cleanup loop.
-->

## Module Scores

| Module | Score | Last reviewed | Notes |
|---|---|---|---|
| TODO: src/api/ | TODO (A/B/C/D) | YYYY-MM-DD | TODO: one-line summary |
| TODO: src/db/ | TODO | YYYY-MM-DD | TODO |

## Score Details

### TODO: module-name (Quality: X)

- **Verification status:** TODO (e.g. all tests passing, 1 flaky test in test_X)
- **Agent comprehensibility:** TODO (clear / acceptable / hard to follow)
- **Test stability:** TODO (stable / flaky N tests)
- **Architecture compliance:** TODO (compliant / known violation: ...)
- **Code conventions:** TODO (followed / partial)
- **Next action if not A:** TODO (specific cleanup tasks)

---

## History

<!--
  One line per score CHANGE — do not log "kept A" every session; merge unchanged
  streaks into one line ("2026-06-30 to 2026-07-02 — backend/app kept A through
  F02-F05"). The Score Details section above is the living snapshot; this log
  only shows the trend.
  Format: YYYY-MM-DD — module — old → new — reason
-->

- TODO: first entry on next review
