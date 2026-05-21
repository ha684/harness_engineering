# features.md

## Feature List

| ID | Behavior | Verification | State | Evidence |
|---|---|---|---|---|
| F01 | POST /api/tasks creates a task and returns 201 with the task's ID | `pytest tests/integration/test_create.py::test_create_task_returns_201` | passing | commit `a3b1c8e` |
| F02 | GET /api/tasks/{id} returns 200 with the task, or 404 if missing | `pytest tests/integration/test_get.py` | passing | commit `c91e2d4` |
| F03 | GET /api/tasks?page=N&size=M returns paginated list, default size=20 | `pytest tests/integration/test_list.py` | passing | commit `d4a72f1` |
| F04 | GET /api/tasks?status=completed filters to completed tasks only | `pytest tests/integration/test_filter.py` | active | — |
| F05 | PATCH /api/tasks/bulk accepts a list of {id, completed} and updates atomically | `pytest tests/integration/test_bulk.py` | not_started | — |
| F06 | DELETE /api/tasks/{id} removes the task, returns 204; 404 if missing | `pytest tests/integration/test_delete.py` | not_started | — |
| F07 | End-to-end smoke: create → list → mark complete → delete, all via HTTP | `pytest tests/e2e/test_lifecycle.py` | blocked | depends on F06 |
| F08 | Fix flaky `test_filter_completed_only` — add ID tiebreak in ORDER BY | `pytest tests/integration/test_filter.py::test_filter_completed_only` (10 runs, all pass) | not_started | — |

## Active

**ID:** F04

**Behavior:** `GET /api/tasks?status=completed` returns only completed tasks. `GET /api/tasks?status=pending` returns only pending. No `status` param → return all.

**Verification command:** `pytest tests/integration/test_filter.py`

**Notes / sub-steps:**
- ✅ Pydantic query model with `status: Literal["completed", "pending"] | None = None`
- ✅ Repo method `find_by_status(status)` added
- ✅ Service wires it up
- ⚠️ Test for `status=both` edge case failing — pending API design decision (see PROGRESS.md → Open Questions)
- ⏳ Run e2e smoke once F04 passes (the smoke test exercises the filter)

## Blocked

**F07** — Blocked on F06 (delete endpoint). Unblock condition: F06 reaches `passing`.

## Passing (this milestone)

- F01 (commit `a3b1c8e`)
- F02 (commit `c91e2d4`)
- F03 (commit `d4a72f1`)
