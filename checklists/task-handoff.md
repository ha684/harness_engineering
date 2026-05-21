# Checklist: Task Handoff (Outsourcing model)

> For client use. Run before delivering a TASK.md to a contractor, and again when reviewing returned work.

---

## Pre-delivery (client → contractor)

### TASK.md quality

- [ ] Scope lists specific files, not just "the auth area"
- [ ] Out-of-scope section exists and names at least 2-3 things the contractor must not touch
- [ ] Each acceptance criterion is behavioral (observable outcome) not implementational ("create X method")
- [ ] Verification command is a single runnable command — tested right now, exits 0 on the current codebase
- [ ] `make check` also passes on current codebase (contractor starts from a green baseline)
- [ ] Context pointers reference specific DECISIONS.md entries and docs sections, not vague "see our conventions"
- [ ] Environment notes cover anything not obvious from `make setup`

### Package to deliver

- [ ] `AGENTS.md` (current version from main)
- [ ] `DECISIONS.md` (current version from main)
- [ ] `TASK.md` (approved)
- [ ] Relevant `docs/` files (architecture.md at minimum; testing.md if they need to write tests)
- [ ] Access to the repo at the correct base commit (or a clean branch)

### In features.md

- [ ] Feature marked `active` with contractor's name/handle in Owner column
- [ ] No other feature blocked by this one is also `active` (dependency check)

---

## Post-delivery (contractor → client review)

### First, mechanical checks

```bash
git fetch && git checkout <contractor-branch>
make check        # must be green before reading anything else
```

- [ ] `make check` exits 0
- [ ] Verification command from TASK.md exits 0 when run independently
- [ ] `git diff main...HEAD` shows changes only in files listed in TASK.md scope
- [ ] No changes in out-of-scope files

### Then, quality checks

- [ ] Evidence section in TASK.md is filled (commit hash + test output)
- [ ] No debug code in diff (`console.log`, `breakpoint()`, `print("DEBUG"...)`)
- [ ] No new `TODO` or `FIXME` added without a corresponding entry in DECISIONS.md → Deferred
- [ ] New tests follow project testing standards (docs/testing.md)
- [ ] No dependency version changes without explicit approval

### Architecture check (if cross-module change)

- [ ] No layer violations (api/ calling repo/ directly, etc.)
- [ ] No new patterns that contradict docs/architecture.md
- [ ] If a new pattern was introduced, it should be in TASK.md Evidence → Notes

---

## If accepting

```bash
# Merge or cherry-pick the contractor's work
# Then update project state:
```

- [ ] Update `features.md`: `active` → `passing`, add commit hash to Evidence column
- [ ] Update `DECISIONS.md` if the task introduced new design choices (ask contractor if unsure)
- [ ] Re-score affected modules in `QUALITY.md` if quality changed

---

## If rejecting (returning for rework)

Fill in TASK.md "Rejection reason" section. Format: **WHAT + WHY + HOW TO FIX**.

- [ ] Which acceptance criterion failed (by name, not just "tests fail")
- [ ] The exact reproduction command
- [ ] Paste the failure output
- [ ] Root cause (your diagnosis, not just symptoms)
- [ ] Fix guidance: specific, points to file:line or docs section
- [ ] Return-by date

Do NOT just say "tests fail, fix it." That is the outsourcing equivalent of an agent declaring victory too early — it pushes the diagnostic work onto the contractor who has less context than you do.

---

## Common failure patterns

| What you see | Likely cause | Fix |
|---|---|---|
| Tests pass but wrong behavior | Verification command too weak | Strengthen the command; add behavioral assertion |
| Changes outside scope | Out-of-scope section was missing or vague | Add explicit prohibitions to TASK.md |
| Contractor asked many questions | Context pointers were vague | Add specific DECISIONS.md references |
| Contractor "also fixed" unrelated things | No out-of-scope section | Always include one |
| make check fails on lint/typecheck | AGENTS.md constraints not read | Confirm contractor read AGENTS.md; add constraint to TASK.md directly |
| Dependency version changed | Not explicitly forbidden | Add to out-of-scope on future tasks |
