# Harness Engineering — Workflow Guide

This document explains **how to actually use** the template kit across projects. README.md tells you what is in the box; this tells you how to operate it.

## Mental model: five subsystems = a kitchen

| Kitchen | Harness | Lecture |
|---|---|---|
| Recipe shelf | `AGENTS.md` + `docs/` | 02, 03, 04 |
| Knife rack | `Makefile` + `scripts/` | 02 |
| Stove | locked dependencies + `make setup` | 02 |
| Prep station | `PROGRESS.md` + `DECISIONS.md` | 05 |
| Quality-check window | `scripts/verify.sh` + `make check` | 02, 09, 10 |

If any of these is missing or rotten, the agent can still produce output, but the output will be unreliable.

---

## Phase 1 — Onboard a new project

You have a new repo (greenfield or existing) and want to bring it under harness discipline.

### Step 1.1 — Copy the templates

```bash
# From this kit
cp -r templates/* /path/to/project/
cp -r templates/.gitignore-additions /path/to/project/.gitignore-additions 2>/dev/null
```

Then in your project, append `.gitignore-additions` content to `.gitignore` if needed.

### Step 1.2 — Run the generator prompt

Open Claude Code (or your agent of choice) in the project directory, and paste **one** of:

- **`prompts/01-generate-from-repo.md`** — if the project already has code. The agent will scan files, infer tech stack, conventions, and verification commands, then propose filled-in `AGENTS.md`, `features.md`, `DECISIONS.md`, etc.
- **`prompts/02-generate-interactive.md`** — if greenfield. The agent will ask you ~10 structured questions and fill the templates from your answers.

**Always review the generated output before committing.** The agent is making educated guesses; you are the source of truth.

### Step 1.3 — Verify the bootstrap contract

From lecture 06, the project is properly bootstrapped only when **all four** conditions hold. See `checklists/bootstrap-contract.md`:

1. `make setup` runs from a clean clone with no manual intervention
2. `make test` exists and has at least one passing test
3. A fresh agent session can answer "what is this / how do I run it / how do I verify it / where are we now" from repo files alone — the cold-start test (`checklists/cold-start-test.md`)
4. `features.md` has at least 3 tasks broken down with verification commands

If any condition fails, fix it before doing any feature work. **Do not mix initialization and feature implementation** (lecture 06).

### Step 1.4 — Commit the checkpoint

```bash
git add AGENTS.md PROGRESS.md DECISIONS.md features.md QUALITY.md Makefile docs/ scripts/
git commit -m "chore: bootstrap harness (AGENTS.md + verification + state files)"
```

This commit is your **warm-start baseline**. All future sessions start from a state at least this good.

---

## Phase 2 — Run a session

### Step 2.1 — Clock in

At the start of every agent session, paste `prompts/03-session-start.md` (or have it preconfigured as a hook / startup instruction). It tells the agent to:

1. Read `PROGRESS.md` (current state)
2. Read `DECISIONS.md` (constraints from past decisions)
3. Run `make check` to confirm the repo is in a consistent state
4. Pick the next `not_started` feature from `features.md`
5. Set its state to `active` and announce what it will do

### Step 2.2 — Work with WIP=1

From lecture 07: **one feature active at a time.** The agent does not "also refactor this while it's here." If it spots something out of scope, it adds a note to `DECISIONS.md` ("noted: X needs cleanup later") and continues with the current feature.

### Step 2.3 — Verify before marking passing

From lectures 09 + 10: the only way a feature moves from `active` to `passing` is by running the verification command and seeing it pass. Three layers:

1. **Static** — `make lint` (syntax, typecheck)
2. **Behavioral** — `make test` (unit + integration)
3. **End-to-end** — feature-specific verification command (curl, playwright, smoke test)

If layer N fails, do not proceed to layer N+1. Fix and re-run.

### Step 2.4 — Clock out (clean handoff)

Before ending the session, paste `prompts/04-session-exit.md` or follow `checklists/session-exit.md`. The agent must confirm **all five** clean-state dimensions:

- Build passes
- Tests pass
- `PROGRESS.md` updated with current state + next steps
- No stale artifacts (temp files, debug logs, commented-out code)
- Standard startup path (`make setup && make dev`) still works

If any dimension is red, fix it before exit. **"Clean up later" means never clean up** (lecture 12).

---

## Phase 3 — Maintain the harness

### Audit `AGENTS.md` size

Every 2 weeks, check if `AGENTS.md` has grown past 200 lines. If it has, split content into `docs/<topic>.md` and replace the section with a one-line link. The entry file is a **router, not an encyclopedia** (lecture 04).

### Update `QUALITY.md`

After each significant session, re-score affected modules. A module drops from B to C when:
- New flaky tests appeared
- Architecture boundaries got violated
- A feature is hard for a new agent to understand

Sessions that find a C-rated module should consider fixing it before adding new features there.

### Periodic harness simplification

From lecture 12: as models improve, some constraints become unnecessary overhead. Once a month, pick one rule in `AGENTS.md`, temporarily remove it, and run a benchmark task. If nothing breaks, remove it permanently.

### Run the cleanup loop

Once a week, run a dedicated cleanup session (no feature work). Use `checklists/session-exit.md` as the inspection list against the whole repo. Target: zero stale artifacts, all builds green, all tests green.

---

## What to do when things go wrong

### "The agent built the wrong thing"

Diagnose against the five failure layers (lecture 01):

1. **Task specification** — was the feature in `features.md` precise enough? Did it have a verification command?
2. **Context provision** — did the agent need to know something that was not in any of `AGENTS.md`, `docs/`, `DECISIONS.md`?
3. **Execution environment** — was a dependency missing? A tool unavailable?
4. **Verification feedback** — did the agent get clear signals when it went wrong, or did it run blind?
5. **State management** — was the previous session's handoff incomplete?

The fix goes into whichever layer was the root cause. Add a rule, a topic doc, a verification command, a `PROGRESS.md` field — whatever closes the gap. **Every failure should make the harness stronger.**

### "The agent keeps re-doing work that was already done"

State subsystem failure. Audit `PROGRESS.md` — is it truthful and current? Are completed features really marked `passing` in `features.md`?

### "Sessions feel slow to start up"

Rebuild cost is too high (lecture 05). Target: < 3 minutes from session open to first productive action. If higher:
- `PROGRESS.md` is too vague — add concrete "next steps"
- Too many topic docs need to be read — consolidate or improve summaries
- `AGENTS.md` lacks the "Quick Start" section

### "The agent declared done but it isn't"

Verification gap (lecture 09). The feature's verification command is too weak or absent. Strengthen it:
- Unit tests passing is **not enough** for cross-component features
- Add an end-to-end verification (curl, browser automation, smoke test)
- Make error messages actionable — they should tell the agent how to fix, not just what failed

---

## File-by-file ownership

| File | Updated by | Frequency |
|---|---|---|
| `AGENTS.md` | You (humans) | Rarely, on architecture changes |
| `docs/*.md` | You + agent | When new patterns emerge |
| `PROGRESS.md` | Agent | Every session, at start and end |
| `DECISIONS.md` | Agent (proposes), you (approves) | On every significant design choice |
| `features.md` | You (initial breakdown), agent (state transitions) | Per feature lifecycle |
| `QUALITY.md` | Agent (proposes), you (reviews) | After significant sessions |
| `Makefile` | You | Rarely, when verification commands change |
| `scripts/*.sh` | You | Rarely |

**Rule:** anything the agent updates regularly should have a clear schema. Anything you own should be brief enough to actually maintain.

---

---

## Team model A — Product development (multi-person, continuous)

Use this when: you have an ongoing product, multiple developers (human or agent), continuous sprints, no hard task boundary.

### What changes vs the single-person model

**Shared truth lives on `main`, never conflicts:**

```
main branch
├── AGENTS.md          ← project constitution, rarely changes
├── DECISIONS.md       ← append-only, PR required to add entries
├── docs/              ← team-maintained architecture + testing docs
├── features.md        ← master tracker (state machine only, see below)
└── QUALITY.md         ← reviewed in weekly cleanup sessions
```

**Per-person state lives on feature branches, never merges to main:**

```
feature/F04-status-filter
└── SESSION.md         ← rename from PROGRESS.md; scoped to this branch only
```

`SESSION.md` is discarded (or squash-merged into a branch summary) when the feature merges. It never touches `main`.

### features.md in a multi-person team

Keep `features.md` on `main` as a state machine tracker only — **no process notes, no sub-steps, no "in progress" prose**. Each row is owned by exactly one person at a time (WIP=1 per feature, not per person):

```
| F04 | Filter by status | pytest tests/integration/test_filter.py | active | @alice |
| F05 | Bulk update      | pytest tests/integration/test_bulk.py  | not_started | — |
```

Add an `Owner` column. Merge conflict rate drops to near zero because each row belongs to one person.

**Scale threshold:** if the team exceeds ~5 people or features exceed ~30 rows, replace `features.md` with GitHub Issues / Linear. In the repo, keep only `CURRENT_TASK.md` — a snapshot of the single feature the current branch is working on (pulled from the tracker at branch creation).

### Sprint / milestone rhythm

```
Sprint start:
  - Human updates features.md: promote next batch from not_started → queued
  - Each dev picks one feature, creates a branch, creates SESSION.md

During sprint:
  - AGENTS.md, DECISIONS.md, docs/ updated via PR with review
  - SESSION.md updated freely on the branch (no review)
  - features.md state transitions (active → passing) via PR

Sprint end / cleanup session:
  - One dedicated cleanup session (lecture 12): no feature work
  - QUALITY.md re-scored for all modules touched this sprint
  - Run cold-start test (checklists/cold-start-test.md)
  - AGENTS.md pruned if it grew past 200 lines
```

### Agent sessions in product mode

Each agent session works on one feature branch. The clock-in/clock-out prompts (`prompts/03-session-start.md`, `prompts/04-session-exit.md`) work unchanged — the agent reads `SESSION.md` instead of `PROGRESS.md`. The only config change: add this to `AGENTS.md`:

```markdown
## State files (multi-person)
- `AGENTS.md`, `docs/`, `DECISIONS.md` — project-wide truth, read-only for agents
- `SESSION.md` (on feature branch) — session state, agent updates freely
- `features.md` on main — state transitions only, updated via PR
```

---

## Team model B — Outsourcing / task-based

Use this when: you hand discrete tasks to contractors, freelancers, or separate agent sessions with no shared context. The contractor should be able to do their work with **only the files you give them** and no verbal briefing.

### The ownership split

```
Client maintains (project knowledge):         Contractor receives (task knowledge):
├── AGENTS.md                                 ├── AGENTS.md (read-only copy)
├── DECISIONS.md                              ├── DECISIONS.md (read-only copy)
├── docs/                                     ├── relevant docs/
└── features.md (master)                      └── TASK.md ← this is the key artifact
```

The contractor does **not** receive `PROGRESS.md` (not relevant), `QUALITY.md` (not their concern), or `features.md` (they only work on one task).

### TASK.md — the contract

`TASK.md` is a scoped mini-sprint contract (lecture 11) for a single outsourced task. Think of it as the intersection of a feature entry from `features.md` and everything the contractor needs to understand to do it safely.

See `templates/TASK.md` for the blank template. The `prompts/05-generate-task-brief.md` prompt can auto-generate a TASK.md from a feature entry + the project's AGENTS.md.

### End-to-end outsource workflow

```
Client (before handing off):
  1. Pick a feature from features.md (must be not_started, not blocked)
  2. Run prompts/05-generate-task-brief.md → produces TASK.md
  3. Review TASK.md: is scope clear? are acceptance criteria testable?
     are the context pointers correct?
  4. Mark feature as active in features.md (so no one else picks it)
  5. Hand contractor: AGENTS.md + DECISIONS.md + TASK.md + relevant docs/

Contractor (doing the work):
  1. Read AGENTS.md (rules), DECISIONS.md (context), TASK.md (the job)
  2. Run make setup to verify environment
  3. Implement against TASK.md acceptance criteria
  4. Run the verification command — must exit 0
  5. Fill in TASK.md "Evidence" section (changed files + test output snippet)
  6. Deliver: code + completed TASK.md

Client (after receiving):
  1. Run make check — must be green
  2. Re-run the verification command independently
  3. If passing: update features.md state to passing, record evidence
  4. If not: return TASK.md with specific failure reason + FIX guidance
     (lecture 10: error messages should tell how to fix, not just what failed)
  5. Update DECISIONS.md if the task introduced new design choices
```

### What makes a good TASK.md

The test: can a skilled contractor complete the task with zero verbal communication, relying only on the files you gave them?

**Good TASK.md:**
- Scope section says exactly which files/modules to touch
- Out-of-scope section says what NOT to touch (prevents drive-by refactors)
- Acceptance criteria are behavioral, not implementation-level
- Verification command is a single runnable command that exits 0 on pass
- Context pointers say "see DECISIONS.md entry 2026-03-01" not "use our auth style"

**Bad TASK.md:**
- "Add the usual auth middleware" (what is "the usual"?)
- "Make sure it's clean" (not verifiable)
- No verification command
- No out-of-scope section (contractor refactors half the codebase "while there")

### When a task comes back broken

Do not just say "tests fail, fix it." That creates a guessing loop. Instead, fill in the TASK.md "Rejection reason" section with:

```
Rejection reason: test_verify_email_expired_token fails (exit 1).
Command: pytest tests/integration/test_verify_email.py::test_expired_token
Output: AssertionError: expected 422, got 200
Root cause (client investigation): the token expiry check is in service layer
  but the test is calling the repo directly, bypassing it.
Fix: move the expiry check into the route handler or call via the service
  in the test (see docs/testing.md "no direct repo calls in integration tests").
```

This mirrors lecture 10's agent-oriented error message pattern — but for human/contractor handoffs.

---

## When NOT to use this template

This kit is overkill for:

- Throwaway one-shot scripts (just write the script)
- Single-session tasks under 30 minutes
- Projects with no agent involvement at all

It pays off for:

- Multi-session work spanning days or weeks
- Codebases where multiple agent sessions (or multiple developers) need to coordinate
- Any project where "the agent confidently broke something" has happened more than once

---

## Next steps

1. Read `examples/fastapi-todo/` to see every template filled in for a real-ish project
2. Try the workflow on a small toy project before deploying it on production work
3. After each project, ask: which template did I never touch? Which one saved me the most time? Iterate on the template kit itself.
