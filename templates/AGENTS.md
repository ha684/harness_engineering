# AGENTS.md

<!-- Keep this short — aim for under ~60 lines. It holds only what an agent
     can't work out by reading the code: commands, where things live, and the
     few constraints that aren't obvious. Every line here is read by every
     session, and long rule lists make current models worse, not better.
     Before adding a rule, check whether a linter, a type check, a test, or a
     spec scenario could carry it instead. -->

TODO: one or two sentences — what this is and who uses it.

## Commands

| Task | Command |
|---|---|
| Install / prepare | `make setup` |
| Run locally | `make dev` |
| Run some tests | `make test T=<path or selector>` |
| Fast static checks | `make lint` |
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

<!-- Only things an agent would plausibly get wrong without being told, each
     with its reason. A rule with a "why" generalizes; a bare rule doesn't. -->

- TODO, e.g. "Database access only in `app/repo/` — `make lint` enforces the layering via import-linter."

## Areas

<!-- Monorepo only; delete otherwise. Root holds what's true in every area;
     stack-specific rules live in each area's own AGENTS.md. -->

- `backend/` — read `backend/AGENTS.md` when working there.
- `frontend/` — read `frontend/AGENTS.md` when working there.
