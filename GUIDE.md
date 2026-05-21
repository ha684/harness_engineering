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
