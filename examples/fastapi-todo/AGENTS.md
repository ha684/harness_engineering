# AGENTS.md

Single-user todo-list REST API (FastAPI, async SQLAlchemy, PostgreSQL).

## Commands

| Task | Command |
|---|---|
| Install / prepare | `make setup` — uv sync, .env, test database in Docker, migrations |
| Run locally | `make dev` |
| Run some tests | `make test T=tests/test_status_filter.py` |
| Fast static checks | `make lint` — ruff, mypy --strict, import-linter |
| Full check (once, when a change is complete) | `make check` |

## Where things are

- What the system must do: `openspec/specs/`. Work in progress: `openspec/changes/`.
- Module map and boundaries: `docs/architecture.md`.
- Project-wide decisions and why: `DECISIONS.md`.
- What past sessions learned the hard way: `lessons/INDEX.md` — open the entries that match what you're about to do.

## How we work

- Changes to what the system does go through an OpenSpec change, even small ones — that's what keeps the specs true. Bug fixes that restore specified behavior, refactors, and obvious low-risk edits don't need one; a bug fix still gets a test that would have caught it.
- If an OpenSpec change is in progress, read its `tasks.md` — including the handoff note at the bottom — before anything else.
- Tests encode spec scenarios; see the `spec-driven-testing` skill. While iterating, run only the tests for what you're changing.
- One change at a time. Problems you notice outside it go in the handoff note as follow-ups.
- Don't commit or push — the user handles version control. When you finish, list the files you changed.

## Constraints

- Database access only in `app/repo/`; handlers call services. `make lint` enforces this with import-linter.
- SQLAlchemy 2.0 style only (`select()`, never `session.query()`) — the legacy API is removed in our version, and mixing styles caused real bugs.
- Everything async: no `def` route handlers, no sync DB calls. A blocking call stalls every request on the event loop.
- Tests use the real PostgreSQL from `make setup`, never a mocked database — mocks hid an ordering bug once already.
