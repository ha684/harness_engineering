# AGENTS.md

> Worked example — a todo-list HTTP API built with FastAPI. Mid-flight (some features passing, one active, several to go).

## Project Overview

`fastapi-todo` is a single-user todo-list REST API used as a teaching example for the harness engineering template. Stores tasks in PostgreSQL, exposes CRUD endpoints plus filtering and bulk operations.

## Tech Stack

- **Language:** Python 3.11
- **Framework:** FastAPI 0.110
- **Database:** PostgreSQL 15 (via asyncpg)
- **ORM:** SQLAlchemy 2.0 (async)
- **Package manager:** uv
- **Test framework:** pytest + pytest-asyncio
- **Lint / typecheck:** ruff + mypy --strict

## Quick Start

```bash
make setup        # uv sync + copy .env.example to .env + run migrations
make dev          # uvicorn app.main:app --reload
make test         # pytest -x
make check        # ruff + mypy + pytest
```

## Hard Constraints

- **MUST** use SQLAlchemy 2.0 syntax (`select()`, not legacy `Query`). Why: 1.x syntax was removed in our SQLAlchemy version, mixing styles caused two production bugs in the source project this example is modeled on.
- **MUST** use async/await throughout — no `def` route handlers, no sync DB calls in async context. Why: blocking the event loop kills request latency under load.
- **MUST NOT** access the database from `app/api/` handlers directly — go through `app/service/`. Why: the layering rule is enforced by an import-linter check in `make lint`. Violating it breaks CI.
- **MUST** parse and validate input at the API boundary using Pydantic models. Why: lecture 10 invariant — data is parsed at the boundary, not deeper.
- **MUST NOT** mock the database in integration tests. Why: lecture-driven, prior mocked tests masked a real migration bug.

## Working Style

- **WIP = 1.** Only one feature is `active` in `features.md` at a time.
- **Verification before declaring done.** Each feature has its own verification command. Static + behavioral + e2e all must pass before `passing`.
- **No drive-by refactors.** Spot something? Add to `DECISIONS.md` → "Deferred".
- **Clean exit.** All five dimensions must hold before ending a session.

## Session Lifecycle

**Clock in:**
1. Read `PROGRESS.md`, `DECISIONS.md`
2. Run `make check` — must be green before doing anything
3. Pick next `not_started` feature, mark `active`

**Clock out:**
1. Run `make check`
2. Update `PROGRESS.md` with done + next steps
3. Remove debug code, commit

## State Files

| File | Purpose |
|---|---|
| `PROGRESS.md` | Current state |
| `DECISIONS.md` | Decision log |
| `features.md` | Feature list with state machine |
| `QUALITY.md` | Per-module quality |

## Topic Docs

- [Architecture](docs/architecture.md) — Read before cross-module changes (api/service/repo boundaries)
- [Testing standards](docs/testing.md) — Read when writing tests

## Verification Commands

| Layer | Command | When required |
|---|---|---|
| Static | `make lint` (ruff) and `make typecheck` (mypy --strict) | Every change |
| Behavioral | `make test` (pytest, includes integration tests against real PG) | Every change |
| End-to-end | `make e2e` (pytest tests/e2e/ — spins up app + DB, runs httpx scenarios) | Cross-component changes |

Individual feature verification commands are in `features.md`.
