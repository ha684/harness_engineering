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

If `make setup` does not produce a runnable environment from a fresh clone, the bootstrap contract is broken — fix that before anything else (see `checklists/bootstrap-contract.md`).

## Hard Constraints

<!--
  Non-negotiable rules. Maximum ~15 entries. Use MUST / MUST NOT.
  Every rule needs a reason (why it exists) so future agents can judge edge cases.
-->

- **MUST** use [convention X]. Why: [reason]
- **MUST NOT** [forbidden action]. Why: [reason]

TODO: list your project's non-negotiable rules.

## Working Style

- **WIP = 1.** Only one feature is `active` in `features.md` at any time. Do not start a new feature while another is active. (lecture 07)
- **Verification before declaring done.** A feature moves to `passing` only when its verification command actually runs and succeeds. "The code looks fine" is not evidence. (lectures 09, 10)
- **No drive-by refactors.** If you spot unrelated cleanup, add a note in `DECISIONS.md` under "Deferred" and continue with the current feature.
- **Clean exit.** Before ending a session, all five clean-state dimensions must hold (see `checklists/session-exit.md`).

## Session Lifecycle

**At session start (clock in):**
1. Read `PROGRESS.md` for current state and next steps
2. Read `DECISIONS.md` for active design constraints
3. Run `make check` to confirm the repo is in a consistent state
4. Pick the next `not_started` feature from `features.md`, mark it `active`

**Before session exit (clock out):**
1. Run `make check` — all must pass
2. Update `PROGRESS.md` with what was done + immediate next steps
3. Remove temporary files, debug logs, commented-out code
4. Commit all completed work with a descriptive message

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

| Layer | Command | When required |
|---|---|---|
| Static | `make lint` | Every change |
| Behavioral | `make test` | Every change |
| End-to-end | `make e2e` (or feature-specific) | Cross-component changes |

Individual features in `features.md` may specify additional verification commands.

## What This File Is Not

This file is a **router**. It points to authoritative information; it does not duplicate it.

- Do not paste in tech stack versions that change frequently — link to a manifest file.
- Do not write multi-paragraph architecture explanations here — they belong in `docs/architecture.md`.
- Do not list every coding convention — link to the linter config and topic docs.

If a section here grows past ~30 lines, extract it.
