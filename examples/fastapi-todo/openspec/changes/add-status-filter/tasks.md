# Tasks: add-status-filter

## 1. Tests from the scenarios
- [x] 1.1 One test per "Filter tasks by status" scenario in `tests/test_status_filter.py`
- [x] 1.2 Test for "Tasks created at the same instant"

## 2. Implementation
- [x] 2.1 `status` query parameter with `Literal["completed", "pending"] | None` in `app/api/tasks.py`
- [x] 2.2 `ORDER BY created_at DESC, id DESC` in `TaskRepo.list` (`app/repo/tasks.py`)
- [ ] 2.3 `status` filter in the same query

## 3. Finish
- [ ] 3.1 `make check`

## Handoff
2026-05-18 — Ordering fixed: the same-instant test passed 20 of 20 runs after 2.2 (failed about one in five before); recorded in `lessons/order-by-tiebreak.md`.
"Unknown status value" and "No filter" pass; the other filter tests fail as expected until 2.3.
Next: 2.3 — add the `status` condition to the query in `TaskRepo.list`.
No open questions.
