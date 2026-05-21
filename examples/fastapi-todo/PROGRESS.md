# PROGRESS.md

## Current State

- **Latest commit:** `d4a72f1` — "feat(F03): add task listing with pagination"
- **Build status:** passing (ruff clean, mypy --strict clean)
- **Test status:** 47/48 passing — `test_filter_completed_only` is flaky on CI (passes locally), see Known Issues
- **Lint status:** clean
- **Active feature:** F04 (task filtering by status)

## Completed (this milestone)

- F01 — Create task endpoint (POST /api/tasks)
- F02 — Get single task endpoint (GET /api/tasks/{id})
- F03 — List tasks with pagination (GET /api/tasks?page=&size=)

## In Progress

- **Feature:** F04 — Filter tasks by completion status
- **What is done so far:** schema updated, repo method `find_by_status` added, integration test written but failing on edge case (status=both)
- **What is blocking completion:** need to decide whether `status=both` should be supported, or whether absence of `status` param should mean "both" implicitly. See "Open Questions" below.

## Known Issues

- `test_filter_completed_only` flaky in CI — works locally. Suspect time-based ordering when two tasks have identical `created_at`. Mitigation: sort tiebreak by ID. Tracked as F08.

## Next Steps

1. Resolve the `status=both` API question (see Open Questions) — block on user decision
2. Once resolved, finish F04: implement the query, verify with `pytest tests/integration/test_filter.py`
3. Fix the flaky test (F08) — should be quick, ~30 min
4. Move on to F05 (bulk update endpoint)

## Open Questions

- **Status filter API shape.** Should `GET /api/tasks?status=completed` be the only way to filter, with no param meaning "all"? Or should we support `status=both` explicitly? Affects API design and OpenAPI docs.

## Session History

- 2026-05-15 09:00 — bootstrap session — set up harness, scaffolded F01-F05 in features.md
- 2026-05-15 14:00 — session 2 — implemented F01, all verification passing, committed `a3b1c8e`
- 2026-05-17 10:30 — session 3 — implemented F02 + F03, committed `d4a72f1`. Started F04, blocked on API design question.
