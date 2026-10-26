# Example: fastapi-todo

A small FastAPI todo API, mid-way through a change, showing every v2 file filled in. The application code isn't included — the files reference `app/` and `tests/` as if they exist — except for one test file that shows what a spec-derived test looks like.

## Where the project is

Create, get and paginated list are done and archived; they make up `openspec/specs/tasks/spec.md`. The change in progress is **add-status-filter**: its tests are written, validation and the ordering fix are in, and the status filter in the repository query is next. The `status=both` question from the v1 example was settled during proposal review — an unknown value is rejected with 422 — and the flaky ordering test turned into a scenario of its own.

## What to look at

| File | Notice |
|---|---|
| `AGENTS.md` | About 40 lines. Commands, a pointer to the map, four constraints — each with its reason, most pointing at the tool that enforces it. |
| `openspec/specs/tasks/spec.md` | The current behavior. Every requirement has scenarios a test can check from outside. |
| `openspec/changes/add-status-filter/` | A complete change: why (`proposal.md`), what (`specs/` delta), how far along (`tasks.md`). |
| `…/tasks.md` → `## Handoff` | All the next session needs, in four lines. This replaces v1's `PROGRESS.md`. |
| `…/specs/tasks/spec.md` | The ordering scenario: the hard case that the flaky test was really about, now a requirement. |
| `tests/test_status_filter.py` | One test per scenario, named after it, through HTTP, no mocks of our own code. |
| `DECISIONS.md` | Three project-wide decisions and a "Not doing" list. Per-change reasoning isn't here — it would be in a change's `design.md`. |
| `lessons/` | One lesson, with its evidence: what failed, what fixed it, how that was confirmed. Read only when someone writes a sorted query. |

## v1 → v2, in this example

| v1 file | Now |
|---|---|
| `features.md` (F01–F08) | F01–F03 → `openspec/specs/tasks/spec.md`; F04 → the active change; F05–F07 → future changes; F08 → a scenario in the active change |
| `PROGRESS.md` | `tasks.md` + its handoff note |
| `QUALITY.md`, `TASK-F04-example.md` | Gone — the change folder is the brief |
