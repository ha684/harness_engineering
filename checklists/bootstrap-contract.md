# Checklist: Bootstrap Contract

> From lecture 06. A project is "bootstrapped" only when all four conditions hold. Run this checklist after using a generator prompt or doing a manual setup.

## The four conditions

### 1. `make setup` runs cleanly

- [ ] From a fresh clone (or `make clean && make setup`), the command completes with exit code 0
- [ ] No manual steps required between cloning and a working dev environment
- [ ] If env vars are needed, `.env.example` exists and the setup either copies it or prints clear next steps

**Test:** clone the repo to a tmp directory and run `make setup`. If it does not work end-to-end, the bootstrap contract is broken.

### 2. `make test` has at least one passing test

- [ ] The test framework is installed and discoverable
- [ ] At least one test exists (a smoke test is OK — `def test_smoke(): assert True`)
- [ ] `make test` exits 0

**Why a smoke test counts:** the bootstrap phase is about proving the verification framework is wired up, not about having complete test coverage. Coverage comes during implementation.

### 3. Cold-start test passes

A fresh agent session, given only the repo files (no chat history, no human briefing), can answer all five questions from `checklists/cold-start-test.md`:

- [ ] What is this system?
- [ ] How is it organized?
- [ ] How do I run it?
- [ ] How do I verify it?
- [ ] Where are we now?

**Test:** open a brand-new Claude Code (or other) session in the repo and ask each question. If any answer is "I don't know" or "let me explore", the harness is incomplete.

### 4. `features.md` has at least 3 tasks with verification commands

- [ ] At least 3 features listed
- [ ] Each has a real, executable verification command (not "TBD" or a placeholder)
- [ ] All initial features are `not_started` (do not pre-claim things as `passing` without evidence)

## If any condition fails

**Stop.** Do not start feature work. Fix the bootstrap. The whole point of initialization-as-a-separate-phase (lecture 06) is that doing feature work on top of an incomplete bootstrap accumulates hidden defects.

Common fixes:

| Failure | Fix |
|---|---|
| `make setup` fails — missing dependency | Add it to the dependency manifest (pyproject.toml etc) and update Makefile |
| `make setup` fails — missing env var | Add to `.env.example` with a placeholder + comment |
| `make test` has no tests | Add a smoke test in the appropriate framework |
| Cold-start question unanswered | Add the missing section to `AGENTS.md` (or a topic doc) |
| Feature has no verification command | Decide what "done" looks like, then write the command. If you cannot, the feature is not well-enough-defined yet — split or clarify it |

## After all four pass

Commit a baseline checkpoint:

```bash
git add AGENTS.md PROGRESS.md DECISIONS.md features.md QUALITY.md Makefile docs/ scripts/
git commit -m "chore: harness bootstrap (passing contract)"
```

This commit is your warm-start baseline. Future sessions begin from a state at least this good.
