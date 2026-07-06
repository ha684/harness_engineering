# AGENTS.md

<!--
  This is the AGENT ENTRY FILE. Target length: 50-200 lines.
  It is a ROUTER, not an encyclopedia (lecture 04).

  If a section grows past ~30 lines, extract it into docs/<topic>.md
  and replace it here with a one-line link + applicability condition.

  Same file applies to Claude Code (as CLAUDE.md), Codex, Cursor.
  If your tool only reads one filename, create a symlink or duplicate.
-->

## Project Overview

<!-- One or two sentences. What is this system, who uses it, why does it exist. -->

TODO: describe the project in 1-2 sentences.

## Tech Stack

<!-- Versions matter. Be specific. -->

- **Language:** TODO (e.g. Python 3.11)
- **Framework:** TODO (e.g. FastAPI 0.110)
- **Database:** TODO (e.g. PostgreSQL 15)
- **Package manager:** TODO (e.g. uv / poetry / pnpm)
- **Test framework:** TODO (e.g. pytest)
- **Lint / typecheck:** TODO (e.g. ruff + mypy --strict)

## Quick Start

```bash
make setup        # Install dependencies, prepare environment
make dev          # Start local dev server
make test         # Run test suite
make check        # Full verification (lint + typecheck + test)
```

If `make setup` does not produce a runnable environment from a fresh clone, the bootstrap contract is broken — fix that before anything else. (Bootstrap contract: `make setup` works from fresh clone; `make test` has ≥1 passing test; a new session can answer what/how-to-run/how-to-verify/where-are-we from repo files alone; `features.md` has ≥3 features with verification commands.)

## Hard Constraints

<!--
  Non-negotiable rules. Maximum ~15 entries. Use MUST / MUST NOT.
  Every rule needs a reason (why it exists) so future agents can judge edge cases.

  MONOREPO: this section holds workflow/process rules that bind EVERY area,
  word for word — typically only 3-7. Litmus test: would this rule be true and
  actionable for a developer who only ever touches the area least related to
  it? If not, it belongs in that area's AGENTS.md, not here. Stack-specific
  rules (async, framework, cloud, lint, region) are never global.
-->

- **MUST** use [convention X]. Why: [reason]
- **MUST NOT** [forbidden action]. Why: [reason]

TODO: list your project's non-negotiable rules.

## Area Routing

<!--
  MONOREPO ONLY — delete this section entirely if this is a single-area project.

  This section tells the agent which area-specific AGENTS.md to load.
  Each area file contains stack-specific rules that extend (not replace) this root file.
  Load ONLY the area relevant to the current task — do not preload all areas.
-->

- Working on `[BE]` feature → also read `backend/AGENTS.md`
- Working on `[FE]` feature → also read `frontend/AGENTS.md`
- Working on `[infra]` feature → also read `infra/AGENTS.md`
- Working on `[BOTH]` feature → split into `[BE]` + `[FE]` sub-features first; tackle sequentially
- TODO: add/remove areas to match your monorepo layout

## Working Style

- **WIP = 1.** Only one feature is `active` in `features.md` at any time — across all areas. Do not start a new feature while another is active. (lecture 07)
- **Verification before declaring done.** A feature moves to `passing` only when its verification command actually runs and succeeds. "The code looks fine" is not evidence. (lectures 09, 10)
- **No drive-by refactors.** If you spot unrelated cleanup, add a note in `DECISIONS.md` under "Deferred" and continue with the current feature.
- **Clean exit.** Before ending a session, all five clean-state dimensions must hold: build green, tests green, `PROGRESS.md` updated, no stale artifacts (debug prints, temp files, commented-out blocks), standard startup path (`make setup` / `make dev`) still works.

## Session Lifecycle

**At session start (clock in):**
1. Read this file — note the Area Routing table
2. Read `PROGRESS.md` for current state and next steps
3. Read `DECISIONS.md` for active design constraints (Active + Deferred only)
4. Read `features.md` — pick the next `not_started` feature, note its Area tag
5. Load area-specific AGENTS.md for that area (monorepo only; skip if single-area)
6. Use the module map in the area's `docs/architecture.md` to locate the feature's touch zone — read only those files, not the whole codebase
7. Run `make check-<area>` (monorepo) or `make check` (single-area) — must be green

**Before session exit (clock out):**
1. Run `make check-<area>` or `make check` — all must pass
2. Update `PROGRESS.md` with what was done + immediate next steps
3. Remove temporary files, debug logs, commented-out code
4. Report which files changed this session — the user handles version control; do not run git write operations (add / commit / push)

## State Files

| File | Purpose | Updated by |
|---|---|---|
| `PROGRESS.md` | Current state, what's done, what's next | Agent, every session |
| `DECISIONS.md` | Design decisions + reasons + deferred items | Agent (proposes), human (approves) |
| `features.md` | Feature list with verification commands and states | Human (breakdown), agent (state) |
| `QUALITY.md` | Per-module quality scores (A/B/C/D) | Agent (proposes), human (reviews) |

## Topic Docs

<!--
  One-line entries: title, link, applicability condition.
  The agent should load these only when relevant to the current task.
-->

- [Architecture](docs/architecture.md) — Read before any cross-module changes
- [Testing standards](docs/testing.md) — Read when writing or modifying tests
- TODO: add project-specific topic docs as the codebase grows

## Verification Commands

<!--
  Three layers (lectures 09, 10). The agent must not declare done if any required layer fails.
-->

| Layer | Single-area | Monorepo (per area) | When required |
|---|---|---|---|
| Static | `make lint` | `make lint-be` / `make lint-fe` | Every change |
| Behavioral | `make test` | `make test-be` / `make test-fe` | Every change |
| End-to-end | `make e2e` | `make e2e` (full stack) | Cross-component / [BOTH] features |
| All layers | `make check` | `make check-be` / `make check-fe` | Before declaring done |

Individual features in `features.md` may specify additional verification commands in their row.

## What This File Is Not

This file is a **router**. It points to authoritative information; it does not duplicate it.

- Do not paste in tech stack versions that change frequently — link to a manifest file.
- Do not write multi-paragraph architecture explanations here — they belong in `docs/architecture.md`.
- Do not list every coding convention — link to the linter config and topic docs.

If a section here grows past ~30 lines, extract it.
