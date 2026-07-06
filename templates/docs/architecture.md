# Architecture

<!--
  Load this doc BEFORE making cross-module changes.

  Keep this file under ~150 lines. If it grows, split by domain into
  docs/architecture-<area>.md and link from here.

  Architectural rules should be EXECUTABLE wherever possible — codify them
  as lint rules or tests, then describe them here. A rule written only
  on paper is a rule that will be violated. (lecture 10)
-->

## System Overview

TODO: one paragraph describing the high-level system. What are the major components and how do they communicate.

## Module Map

<!--
  This is the NAVIGATION INDEX — the map a session uses to find its touch zone
  without scanning the codebase. One line per module (or key file) stating
  WHERE RESPONSIBILITY LIVES. Do not describe file contents (functions,
  signatures) — that rots within sessions; responsibility placement is stable.

  MAINTENANCE: whenever a session adds/moves/renames/deletes a source file,
  it must update this map at session exit. A stale map is worse than no map —
  the next session trusts it and goes to the wrong place.
-->

```
TODO: ASCII or directory tree showing top-level modules

src/
├── api/        # HTTP layer — request validation, response shaping
├── service/    # Business logic — orchestrates repos, enforces invariants
├── repo/       # Data access — only place that talks to the database
└── types/      # Shared type definitions
```

As modules grow, break the tree down to key files with one-line responsibilities:

```
repo/
├── messages.py   # DynamoDB message store — sequence assignment, cursor pagination
└── fanout.py     # Redis pub/sub — publisher + ref-counted subscriber
```

## Dependency Rules

<!--
  Lecture 10 example: layered domain architecture.
  Dependencies flow forward only: Types → Config → Repo → Service → Runtime → UI.
  Codify this with an import-graph lint rule if your stack supports it.
-->

- `api/` may depend on `service/` and `types/`. **MUST NOT** depend on `repo/` directly.
- `service/` may depend on `repo/` and `types/`. **MUST NOT** depend on `api/`.
- `repo/` may depend on `types/` only.
- Cross-cutting concerns (auth, logging) enter through explicit Provider interfaces.

**Executable check:** TODO — add a lint rule (e.g. import-linter for Python, eslint-plugin-import for JS) and reference the config here.

## Invariants

<!--
  Lecture 10: enforce invariants, don't micromanage implementation.
  Each invariant should ideally have a test or lint that catches violations.
-->

- TODO: e.g. "All external input is parsed/validated at the API boundary, not deeper."
- TODO: e.g. "Database connections are acquired and released within a single request scope."

## Common Patterns

- TODO: error handling pattern (link to example file:line)
- TODO: authentication pattern
- TODO: pagination convention

## What Belongs Where

| Concern | Layer | Example |
|---|---|---|
| Request validation | api/ | Pydantic models, FastAPI dependencies |
| Business rules | service/ | Domain logic, cross-entity invariants |
| Persistence | repo/ | SQL queries, ORM sessions |
| Cross-cutting | providers/ | Logging, metrics, feature flags |

## When This Doc Is Wrong

If you find that the code does not match what this document says, **stop and ask** before changing either. The mismatch itself is a signal that someone (human or agent) drifted from the convention, and it needs a deliberate decision: update the doc, or fix the code. Do not silently align one to the other.
