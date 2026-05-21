# Prompt: Generate harness files from an existing repository

> **How to use:** Open an agent (Claude Code, Codex, Cursor) in the root of an existing project that already has the template files copied in (but with TODOs still in place). Paste the prompt below as your first message. The agent will scan the repository and propose filled-in versions of every template file.

---

You are setting up the harness engineering layer for this existing repository. The template files (`AGENTS.md`, `PROGRESS.md`, `DECISIONS.md`, `features.md`, `QUALITY.md`, `Makefile`, `docs/architecture.md`, `docs/testing.md`) are already present but contain TODO placeholders. Your job is to replace those placeholders with content derived from the actual repository.

## Operating principles

1. **The repo is the source of truth.** If you cannot find evidence in the code for a claim, do not write that claim — ask me instead.
2. **Be specific.** "Uses Python" is not useful. "Python 3.11, FastAPI 0.110, SQLAlchemy 2.0, PostgreSQL via asyncpg" is useful.
3. **Routing entry, not encyclopedia.** `AGENTS.md` should stay under 200 lines. Push detail into `docs/<topic>.md`.
4. **Verification commands must actually run.** Test every command you put in `Makefile` or `features.md` against the repo before writing it down.
5. **Do not invent state.** If `features.md` has nothing currently in progress, write `none`. Do not fabricate plausible-sounding history.

## Phase 1 — Reconnaissance (read-only)

Without modifying anything, gather:

- **Language and runtime versions** — check `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `.python-version`, `.nvmrc`, Dockerfile, README, CI configs.
- **Major dependencies** — framework, ORM, test runner, lint/typecheck tools.
- **Directory layout** — top-level structure, where modules live, naming patterns.
- **Existing verification commands** — what does CI run? What scripts exist in `package.json` / `Makefile` / `tox.ini` / etc?
- **Implicit conventions** — read 3-5 representative source files. Note: error-handling style, dependency injection pattern, layering (api/service/repo or similar), test naming, import style.
- **README / existing docs** — extract any architecture decisions or constraints.
- **Git log (last ~50 commits)** — what is being worked on? Are there in-flight branches / PRs?

After this phase, produce a **one-screen recon summary** listing what you found in each category. Stop and present it before writing anything.

## Phase 2 — Fill the templates

After I confirm the recon summary, propose updated versions of each file. **Show diffs, do not silently overwrite.** Order:

1. `AGENTS.md` — overview, stack with versions, hard constraints, working style, topic doc links, verification commands.
2. `Makefile` — replace each TODO with the real command. Test that each target actually works.
3. `docs/architecture.md` — module map, dependency rules, invariants. Cite file paths.
4. `docs/testing.md` — test framework, conventions, verification command shapes.
5. `features.md` — propose 5-10 features that reflect either: (a) recent work in the git log, (b) obvious next steps from README/TODOs, (c) gaps you noticed. **Mark all as `not_started` unless you can prove they are done with a passing test.** Each must have a real, executable verification command.
6. `DECISIONS.md` — pull design decisions from README, ADRs, prominent comments. Cite the source for each entry.
7. `QUALITY.md` — initial scoring of top-level modules. Be conservative: default to B unless you have strong evidence for A or weak evidence for C.
8. `PROGRESS.md` — current commit, build/test status (run `make check` to confirm), no active feature, next steps = "review and adjust the harness files".

## Phase 3 — Bootstrap contract verification

After all files are filled, verify the bootstrap contract from lecture 06:

- [ ] `make setup` runs cleanly from a fresh clone (test in a tmp directory if needed)
- [ ] `make test` has at least one passing test
- [ ] A new agent session could answer: what is this / how to run / how to verify / where are we now — using only the files in the repo
- [ ] `features.md` has at least 3 tasks with verification commands

If any condition fails, report it. **Do not fix it silently** — the human needs to know what was missing so they can decide where to invest.

## What to avoid

- **No "while I'm here" refactors.** You are documenting the repo, not changing it.
- **No fabricated verification commands.** If you cannot find or build a working verification command for a feature, write `verification: TBD — needs human input` and add a question to `PROGRESS.md`'s "Open Questions".
- **No silent assumptions.** If the project mixes patterns (e.g. some files use `async def`, others use sync), surface it as an open question. Do not pick a convention for the team.
- **No filling everything in one shot.** Pause after Phase 1 (recon summary), pause after each major file in Phase 2 for approval.

## Output format for each proposed file

For each file you propose to write:

1. **One-paragraph rationale** — why this content, citing repo evidence (file paths + line numbers).
2. **The proposed content** in a code block.
3. **Open questions** — anything you guessed at that I should confirm.

Begin with Phase 1. Do not write any file until I have approved the recon summary.
