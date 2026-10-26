# Architecture

## Overview

One FastAPI service over PostgreSQL. Requests are validated at the HTTP boundary by Pydantic models, business rules live in services, and repositories hold every query.

## Module map

```
app/
├── api/tasks.py        # routes + request/response models (validation happens here)
├── service/tasks.py    # task rules: defaults, pagination limits, status semantics
├── repo/tasks.py       # all SQL for tasks
├── db.py               # engine + session lifecycle
└── main.py             # app factory, router wiring
tests/
├── conftest.py         # app client + real-DB fixtures, one transaction per test
└── test_*.py           # one file per capability or change, tests named after scenarios
migrations/             # alembic
```

## Boundaries

- `api → service → repo`; nothing skips a layer. Enforced by import-linter in `make lint`.

## If this doc and the code disagree

Point it out rather than quietly aligning one to the other — which one is right is the user's call.
