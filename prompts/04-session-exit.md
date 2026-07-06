# Prompt: Session exit (clock out / clean handoff)

> **How to use:** Paste this when you (or the agent) are about to end a session. The agent will walk through the five clean-state dimensions and refuse to declare done if any are red.

---

You are ending a session. Before exiting, complete the clock-out routine. **A session is not over until clean handoff is verified.** "Clean up later" means never clean up (lecture 12).

## The five dimensions

For each dimension, report PASS or FAIL with evidence. If any is FAIL, **fix it now — do not exit.**

### 1. Build passes

Run `make lint && make typecheck`.

- PASS if both exit 0.
- FAIL otherwise. Show the failing output. Fix it.

### 2. Tests pass

Run `make test`.

- PASS if exit 0 with no failures (skipped tests are OK only if they have an explicit reason logged in `DECISIONS.md` → "Deferred").
- FAIL otherwise. Show the failing output. Fix it.

For features that were marked `passing` this session, also re-run their specific verification commands from `features.md`. **A feature is not really passing until its own verification command exits 0 on demand.**

### 3. PROGRESS.md updated

Open `PROGRESS.md` and confirm:

- [ ] "Current State" reflects the latest commit, build status, test status
- [ ] "Completed" includes any features moved to `passing` this session
- [ ] "In Progress" reflects reality (empty if no feature is `active`, or accurately describes the current active feature's sub-state)
- [ ] "Known Issues" is current (new bugs added, fixed ones removed)
- [ ] "Next Steps" gives the next session a concrete first action (not vague — "fix the bug" is wrong; "investigate why test_create_user fails with empty payload, see line 47" is right)
- [ ] "Session History" has an entry for this session

**Then compact.** State files are read at the start of every future session — every stale line is a recurring context tax. As part of this dimension:

- Compress Session History entries older than the most recent 1-2 to a single line each: `date — what shipped → verification result`, with a pointer (DECISIONS.md entry, docs/ file, commit hash) for anything worth keeping in detail.
- Compress "Completed" bullets to one line per feature — no test counts, no file lists (features.md Evidence + git log carry those).
- In `DECISIONS.md`: tighten settled decisions (no longer actively debated) to the essential Decision / Reason / Rejected / Constraint lines. Compress Superseded entries hardest — one line for what it was, one for why it was replaced. Never delete a decision or break a supersession chain — only shorten prose. If Superseded exceeds ~5 entries, move the oldest to `docs/decisions-archive.md`.
- Do not restate across files what one file already owns: PROGRESS points to DECISIONS for reasoning, to QUALITY for module health, to docs/ for mechanisms.

Rough size targets: PROGRESS.md under ~100 lines, DECISIONS.md active section under ~150. If a file is well past target, compact it now — do not defer to a "cleanup later" that never comes.

### 4. No stale artifacts

Search changed files for:

- `console.log`, `print(...)` debug calls, `debugger;`, `import pdb`, `breakpoint()`
- Commented-out blocks left as "in case I need to put it back" — delete them, git remembers
- Temporary files: `*.tmp`, `debug-*.log`, scratch directories
- `TODO: REMOVE`, `XXX`, `FIXME` you added — either fix or convert to a real tracked item in `DECISIONS.md` → "Deferred"

If anything is found, remove it.

### 5. Standard startup path works

Confirm:

- [ ] `make setup` would still run cleanly from a fresh clone (no manual steps you forgot to add to the Makefile)
- [ ] `make dev` still starts the application

If you added new dependencies, environment variables, or migrations, `make setup` must reflect them.

## Final actions

Once all five dimensions are PASS:

1. **Capture decisions.** Scan the conversation: were any non-trivial technical choices made during implementation that are not yet in `DECISIONS.md`? (IaC tool choice, strict vs standard typing, persistence strategy, third-party service selection, rejected alternatives.) Append them now — an informal decision that stays only in chat is lost at next session.
2. **Quality re-score (if applicable).** If this session significantly affected a module's quality (added/removed flaky tests, violated/restored boundaries), update `QUALITY.md`.
3. **Summarize.** In your final message to the user, state:
   - Features moved to `passing`
   - Features still `active` or `blocked` and why
   - Which files changed this session (code + harness-state files) — the user handles version control themselves; do not run any git write operations (add / commit / push)
   - Next session's first concrete action
   - Anything the user needs to decide before next session

## Failure modes to watch for

- **Hand-waving on dimension 3.** "I updated PROGRESS.md" — did you, or did you generalize? Re-read it. Would a fresh agent know exactly what to do next?
- **Skipping the verification re-run on features marked passing.** Verification can be flaky or environment-dependent. Re-running it confirms the feature is durably done.
- **Exiting without inspecting the diff.** Review every file you changed this session. If you do not understand a change in the diff, that is a signal something happened that you did not notice.

Begin dimension 1 now.
