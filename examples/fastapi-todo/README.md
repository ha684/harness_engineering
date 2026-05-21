# Worked example: fastapi-todo

This directory shows what every template file looks like **after** being filled in for a real-ish project. Use it as a reference when bootstrapping your own projects.

## What this example illustrates

Imagine a small FastAPI todo service that has been worked on for 3 sessions. The harness state files reflect that history:

- **3 features completed** (F01-F03) — task creation, get-by-id, paginated list
- **1 feature active** (F04) — status filter, blocked on an API design question
- **3 features queued** (F05-F07) — bulk update, delete, end-to-end smoke
- **1 known issue** (F08) — flaky test waiting for a tiebreak fix

## What to study

| File | What to notice |
|---|---|
| `AGENTS.md` | Stays under 100 lines. Hard constraints have reasons. Verification commands are concrete. |
| `PROGRESS.md` | "Next Steps" is specific enough that the next session can act without asking. Open Questions block forward motion until resolved. |
| `DECISIONS.md` | Each entry has reason + rejected alternative + going-forward constraint. The "Deferred" section captures temptations to refactor mid-flight. |
| `features.md` | Triple structure: behavior + verification + state. State transitions reflect WIP=1 (only F04 is `active`). |
| `QUALITY.md` | Scores have reasons. The "Next action if not A" field tells you exactly what to fix to upgrade. |
| `Makefile` | Stable target names. `make check` is the single command that runs all three verification layers. |

## What is NOT in this example

To keep the example focused on harness state, the actual `app/` source code is **not** included. In a real project, you would have `app/api/`, `app/service/`, `app/repo/`, `tests/`, `alembic/migrations/`, etc. The harness state files reference those paths as if they exist.

## How to use this

1. Read it end to end once — it takes ~10 minutes.
2. When bootstrapping your own project, refer back to specific files when you are unsure about phrasing or level of detail.
3. Notice what the example does NOT include: no flowery prose, no implementation details in `AGENTS.md`, no "TODO: think about this later" — every section is either concrete or explicitly marked deferred.
