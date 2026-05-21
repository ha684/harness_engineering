# DECISIONS.md

## Active Decisions

### 2026-05-17: Use httpx + real PostgreSQL for integration tests, not mocked DB

- **Decision:** Integration tests run against a real PostgreSQL test database, started via Docker Compose in `make setup-test-db`.
- **Reason:** Lecture 10's blind-spot argument. Mocking the database hides cross-layer state issues (e.g. our `created_at` ordering bug from F03 would not have shown up with a mock).
- **Rejected alternative:** `pytest-mock` + an in-memory fake. Rejected because async SQLAlchemy 2.0 has subtle behavior around session scoping that fakes won't reproduce.
- **Constraint going forward:** CI must provision PostgreSQL. New integration tests should not introduce mocks for DB calls.

### 2026-05-15: Layered architecture — api → service → repo (no shortcuts)

- **Decision:** Strict layering. API handlers call services. Services call repos. Repos own all SQL. No layer skipping.
- **Reason:** Predictable test seams. Each layer testable in isolation, with integration tests covering the seams.
- **Rejected alternative:** "Service-only" pattern (one service class with DB calls inline). Rejected because it makes substituting test doubles harder and tends to grow into a god-object.
- **Constraint going forward:** `import-linter` rule (`pyproject.toml`) enforces this — violations fail `make lint`.

### 2026-05-15: SQLAlchemy 2.0 async, not 1.x sync

- **Decision:** Async throughout — async route handlers, async session, asyncpg driver.
- **Reason:** Project goal is to exercise modern Python async stack. Mixing sync and async creates traps.
- **Rejected alternative:** Sync SQLAlchemy 1.x. Easier to learn but the syntax is being removed in newer versions, and mixing with FastAPI's async core requires running sync calls in a thread pool — adds latency and confusion.
- **Constraint going forward:** No `def` route handlers. No `Session.query()` calls. Reviewer checks every PR.

## Deferred Items

- **Refactor task creation timestamps to use DB-side `now()`.** Currently set in service layer. Works fine but means tests can stub time. Not blocking. Schedule a dedicated session after F05.
- **Add OpenAPI examples for each endpoint.** Quality-of-life for API consumers, not blocking.
- **Investigate switching from uv to PDM.** uv is fast but PDM has better lockfile semantics. Low priority.

## Superseded Decisions

(none yet)
