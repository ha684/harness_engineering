# DECISIONS.md

## 2026-05-17 — Real PostgreSQL in tests, no mocked database

- **Decision:** Tests run against a real PostgreSQL started by `make setup` (Docker Compose).
- **Why:** A mocked session hid an ordering bug in the list endpoint; async SQLAlchemy's session behavior isn't reproducible with fakes.
- **Rejected:** In-memory fakes via pytest-mock.
- **Implies:** CI provisions PostgreSQL. Only third-party services and the clock may be faked.

## 2026-05-15 — Layered: api → service → repo

- **Decision:** Handlers call services, services call repos, repos own all SQL.
- **Why:** Predictable seams; each layer has one job.
- **Rejected:** A single service layer with inline queries — it drifts into a god object.
- **Implies:** import-linter in `make lint` fails any layer skip.

## 2026-05-15 — Async SQLAlchemy 2.0 throughout

- **Decision:** Async handlers, async sessions, asyncpg.
- **Why:** FastAPI is async at the core; mixing in sync DB calls needs thread pools and creates traps.
- **Rejected:** Sync SQLAlchemy 1.x.
- **Implies:** No `def` handlers, no `session.query()`.

## Not doing (for now)

- OpenAPI examples per endpoint — revisit when there's an external consumer.
- Switching uv → PDM — revisit if lockfile problems show up.
- DB-side `now()` for timestamps — revisit if clock-dependent tests become a problem.
