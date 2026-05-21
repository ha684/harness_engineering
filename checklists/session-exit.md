# Checklist: Session Exit (Clean Handoff)

> From lecture 12. Session completion = task verified AND clean state. All five dimensions must hold.

## Quick run

```bash
bash scripts/session-exit-check.sh
```

If automation passes, you may still want to walk through the manual items below — the script catches the mechanical failures, not the judgment ones.

## The five dimensions

### 1. Build passes

- [ ] `make lint` exits 0
- [ ] `make typecheck` exits 0

No warnings tolerated unless they are tracked in `DECISIONS.md` → "Deferred" with a reason.

### 2. Tests pass

- [ ] `make test` exits 0, zero failures
- [ ] Any test marked `skip` has a comment explaining why and a tracking entry in `DECISIONS.md`
- [ ] If any feature was moved to `passing` this session, its specific verification command from `features.md` re-runs cleanly (a feature is not really passing until its own command works on demand, not just as part of the full suite)

### 3. PROGRESS.md updated

- [ ] "Current State" reflects the latest commit + build status + test status (truthfully, not aspirationally)
- [ ] "Completed" includes any features moved to `passing` this session
- [ ] "In Progress" matches reality: empty if no `active` feature, or describes the current `active` feature's sub-state
- [ ] "Known Issues" updated: new bugs added, fixed ones removed
- [ ] "Next Steps" gives a concrete first action for the next session
  - Bad: "fix the bug"
  - Good: "investigate why `test_create_user` fails when payload is empty, see `tests/test_users.py:47`"
- [ ] "Session History" has an entry for this session

### 4. No stale artifacts

Run `git diff HEAD` (or check unstaged changes) and grep for:

- [ ] No `console.log`, `print("DEBUG"...)`, `debugger;`, `import pdb`, `breakpoint()` left in
- [ ] No commented-out blocks "in case I need them" — delete; git remembers
- [ ] No `*.tmp`, `debug-*.log`, scratch files in the working tree
- [ ] No `TODO: REMOVE`, `XXX`, freshly added `FIXME` that did not exist before the session
- [ ] No half-finished functions / dead code paths

If found, remove. **Do not commit them with a "clean up next session" plan.**

### 5. Standard startup path works

- [ ] `make setup` is idempotent — running it on an already-set-up clone does not break things
- [ ] If new dependencies were added: they are in the manifest (pyproject.toml / package.json), not just in your local env
- [ ] If new env vars were added: `.env.example` updated
- [ ] If new migrations were added: `make setup` includes the migration step
- [ ] `make dev` still starts the application without errors

## Final actions (after all five pass)

### 1. Commit

Stage specific files (do NOT `git add -A`):

```bash
git add <changed-source-files>
git add PROGRESS.md features.md DECISIONS.md QUALITY.md  # harness state
git commit -m "<descriptive message>"
```

Commit message style: imperative, mentions feature ID if applicable.
- Good: `feat(F04): filter tasks by status — passes integration tests`
- Bad: `update stuff`

### 2. Quality re-score (if applicable)

If this session significantly affected a module's quality, update `QUALITY.md`:

- New flaky tests → downgrade
- Architecture violation fixed → upgrade
- New module added → score it

### 3. Summarize for the human

Final message should state:

- What was completed (with commit hashes)
- What is still in progress or blocked, and why
- The next session's first concrete action
- Anything the human needs to decide before next session can proceed

## Anti-patterns

- **"I'll commit it as WIP and clean up later."** Lecture 12: clean up later means never. The next session inherits the mess and has its own work to do; it will pile on top.
- **"The build is red but my changes are unrelated."** Then your session is leaving the build red. That is dimension 1 failing. Fix it, or revert.
- **"PROGRESS.md is mostly the same."** Mostly is not enough. The next session reads this file as the single source of truth — if it does not reflect reality, the next session diverges from reality.
