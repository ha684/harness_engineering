# TASK.md — worked example (F04)

> This is an example of a filled-in TASK.md for the fastapi-todo project.
> Study it alongside `templates/TASK.md` to understand what "good" looks like.

## Task metadata

- **Task ID:** F04
- **Title:** Add task filtering by completion status
- **Linked feature:** `features.md` row F04
- **Estimated session length:** 2-3 hours
- **Date issued:** 2026-05-18
- **Issued by:** @alice (project lead)

---

## Scope — what to change

- `app/api/tasks.py` — add optional `status` query parameter to the list endpoint
- `app/service/task_service.py` — add `list_by_status(status)` method, or extend `list_tasks`
- `app/repo/task_repo.py` — add filtered query method (see note below)
- `tests/integration/test_filter.py` — write integration tests (file does not exist yet, create it)

## Out of scope — do NOT change

- `app/db/migrations/` — no schema changes needed, the `completed` column already exists
- `app/api/auth.py` or any auth-related file — this task has no auth component
- `tests/integration/test_list.py` — do not modify existing pagination tests
- Any existing test file — only create new ones
- `pyproject.toml` — do not add or upgrade dependencies

---

## Acceptance criteria

1. `GET /api/tasks?status=completed` returns only tasks where `completed = true`
2. `GET /api/tasks?status=pending` returns only tasks where `completed = false`
3. `GET /api/tasks` (no `status` param) returns all tasks (existing behavior unchanged)
4. `GET /api/tasks?status=invalid` returns 422 with a validation error
5. All filtering results still respect pagination (`page` and `size` params from F03)
6. Each above scenario has a corresponding integration test

## Verification command

```bash
pytest tests/integration/test_filter.py -v
```

Full check (must also pass):
```bash
make check
```

---

## Context for the contractor

### Decisions affecting this task

- See `DECISIONS.md` entry **2026-05-17: SQLAlchemy 2.0 async** — all queries must use `select()` syntax, not legacy `Query`. The new `find_by_status` method in the repo must follow the same pattern as the existing `find_all` method in `app/repo/task_repo.py`.
- See `DECISIONS.md` entry **2026-05-15: Layered architecture** — the route handler must call the service, which calls the repo. Do not call the repo from the route handler directly. This is enforced by `import-linter` in `make lint`, so a violation will fail CI.
- See `DECISIONS.md` entry **2026-05-17: Real DB in integration tests** — the integration tests must use the real PostgreSQL test database (`make setup-test-db`), not a mock. Follow the fixture pattern in `tests/conftest.py`.

### Architecture constraints

- See `AGENTS.md` → Hard Constraints: "MUST use SQLAlchemy 2.0 syntax" and "MUST use async/await throughout". These apply to any new repo method.
- See `docs/architecture.md` → Dependency Rules: api → service → repo. No layer skipping.

### Relevant files to read first

1. `app/repo/task_repo.py` (whole file, ~60 lines) — `find_all` is the model to follow for the new `find_by_status` method
2. `app/service/task_service.py` — how the service calls the repo and shapes the response
3. `app/api/tasks.py` — how the existing `GET /api/tasks` route is structured (query param injection pattern)
4. `tests/integration/test_list.py` — this is the test file pattern to follow for `test_filter.py`
5. `tests/conftest.py` — async DB session fixture used in all integration tests

### Environment notes

- Run `make setup-test-db` before running integration tests. This starts a PostgreSQL test container on port 5433.
- The test database URL is automatically set by the test fixture in `conftest.py` — no env var needed.
- If `make setup-test-db` fails with "port already in use", run `docker compose down` first.

---

## Deliverables checklist

- [ ] All 6 acceptance criteria verified manually
- [ ] `pytest tests/integration/test_filter.py -v` exits 0
- [ ] `make check` passes (lint + typecheck + all tests including existing ones)
- [ ] No changes outside declared scope
- [ ] No debug code, temp files, commented-out blocks
- [ ] Evidence section below is filled in

---

## Evidence *(filled by contractor)*

- **Completion date:** 2026-05-19
- **Commit hash:** `e8f3a21`
- **Verification command output:**

```
tests/integration/test_filter.py::test_filter_completed PASSED
tests/integration/test_filter.py::test_filter_pending PASSED
tests/integration/test_filter.py::test_no_filter_returns_all PASSED
tests/integration/test_filter.py::test_invalid_status_returns_422 PASSED
tests/integration/test_filter.py::test_filter_respects_pagination PASSED
tests/integration/test_filter.py::test_filter_empty_result PASSED

6 passed in 1.24s
```

- **`make check` status:** passing (ruff clean, mypy --strict clean, 53/53 tests)
- **Notes:** Added `status: Literal["completed", "pending"] | None = None` as a Pydantic query param on the route. The repo method is `find_filtered(status)` — returns all if status is None, otherwise filters. Pagination is applied after filtering in the same query. No deferred items.

---

<!--
  Rejection reason section intentionally blank — task was accepted on first submission.
  In a real rejection scenario, the client would fill this in following the pattern
  in checklists/task-handoff.md.
-->
