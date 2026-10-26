# Proposal: add-status-filter

## Why

Users with a long task list need to see only what's left to do, or only what's done. Today the list endpoint returns everything.

## What changes

- `GET /api/tasks` accepts an optional `status` query parameter: `completed` or `pending`. Without it, all tasks are returned, as now.
- Any other value is rejected with 422. We considered accepting `status=both` as an explicit "all"; leaving the parameter out already means that, and two spellings of the same request would have to stay consistent forever.
- Listing order becomes deterministic when tasks share a `created_at`, with `id` as the tiebreak. Filtering makes the existing ordering ambiguity visible — the flaky ordering test was this bug.

## Out of scope

- Filtering by anything other than status (due date, text search).
- Multiple status values in one request.
- Changes to pagination.

## Impact

- `app/api/tasks.py` — query parameter and validation.
- `app/repo/tasks.py` — filtered query and the ordering tiebreak.
- Spec capability: `tasks`.
