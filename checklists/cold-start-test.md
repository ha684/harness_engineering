# Checklist: Cold-Start Test

> From lecture 03. The fastest way to detect harness gaps: open a brand-new agent session and see if it can answer five basic questions from repo contents alone.

## How to run the test

1. Open a fresh Claude Code (or Codex / Cursor) session in the project root.
2. Provide no briefing, no chat history, nothing — just the repo.
3. Ask each question below, one by one.
4. For each, evaluate the answer against the criteria.

If the agent has to grep extensively or hallucinate plausible-sounding details, the answer fails. The agent should be able to point at a specific file and quote it.

## The five questions

### 1. What is this system?

**Pass criteria:** the agent gives a 1-3 sentence answer about the project's purpose, pointing at `AGENTS.md` or `README.md`.

**Fail signals:** the agent says "let me look around" and starts opening source files to guess.

**Fix if fail:** add a "Project Overview" section to `AGENTS.md`.

### 2. How is it organized?

**Pass criteria:** the agent describes the major modules and their responsibilities, pointing at `docs/architecture.md` (or the architecture section of `AGENTS.md`).

**Fail signals:** the agent runs `ls` and tries to infer structure from filenames.

**Fix if fail:** add `docs/architecture.md` with at minimum a module map and dependency rules.

### 3. How do I run it?

**Pass criteria:** the agent says "run `make setup` then `make dev`" (or equivalent), citing the Makefile.

**Fail signals:** the agent says "probably `npm install && npm run dev`" without checking; or "let me look at package.json".

**Fix if fail:** add a Makefile with stable target names (`setup`, `dev`, `test`, `check`). Document them in `AGENTS.md` → Quick Start.

### 4. How do I verify it?

**Pass criteria:** the agent says "run `make check`, which is lint + typecheck + test", citing `AGENTS.md` or Makefile.

**Fail signals:** the agent guesses test commands or asks the user.

**Fix if fail:** add verification commands to `AGENTS.md` and ensure the Makefile has `check` wired up.

### 5. Where are we now?

**Pass criteria:** the agent reads `PROGRESS.md` and reports the active feature, the next concrete step, and any open questions. Bonus if it cross-references `features.md`.

**Fail signals:** the agent says "I'm not sure, let me check git log" or invents progress.

**Fix if fail:** ensure `PROGRESS.md` exists and has current "Active feature" + "Next Steps" + "Open Questions" filled in.

## Scoring

- **5/5:** harness instruction subsystem is healthy. New sessions will be productive within 3 minutes.
- **3-4/5:** workable but slow. New sessions will spend extra time exploring.
- **0-2/5:** instruction subsystem is broken. Every new session will waste significant context budget.

## When to re-run

- After any large change to `AGENTS.md` or the topic docs
- After splitting `AGENTS.md` (lecture 04) — confirm splits did not break discoverability
- Periodically (every 2-4 weeks) — knowledge decays as code evolves
- When a new session feels slow to start — measure don't guess
