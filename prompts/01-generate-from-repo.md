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

- **Repo structure type** — check the top-level layout first. Is this a single-area repo (one language, one framework) or a **monorepo** (multiple distinct areas like `backend/`, `frontend/`, `infra/`, `mobile/`)? List every top-level directory that contains independent code with its own stack or tooling. This determines whether you generate one AGENTS.md or a tiered set.
- **Language and runtime versions per area** — check `pyproject.toml`, `package.json`, `go.mod`, `Cargo.toml`, `.python-version`, `.nvmrc`, Dockerfile, README, CI configs. In a monorepo, do this per area.
- **Major dependencies per area** — framework, ORM, test runner, lint/typecheck tools.
- **Directory layout** — top-level structure, where modules live, naming patterns within each area.
- **Existing verification commands** — what does CI run? What scripts exist in `package.json` / `Makefile` / `tox.ini` / etc? Note area-specific targets (e.g. `test-be`, `test-fe`) vs unified targets.
- **Implicit conventions** — read 3-5 representative source files per area. Note: error-handling style, dependency injection pattern, layering, test naming, import style.
- **IaC tooling** (if infra/ area exists) — is there Terraform, CDK, Pulumi, or shell-only provisioning? What cloud target?
- **README / existing docs** — extract any architecture decisions or constraints.
- **Git log (last ~50 commits)** — what is being worked on? Are there in-flight branches / PRs?

After this phase, produce a **one-screen recon summary** with an explicit section: **"Repo type: single-area / monorepo"**. If monorepo, list each area, its stack, and its top-level directory. Stop and present before writing anything.

## Phase 2 — Fill the templates

After I confirm the recon summary, propose updated versions of each file. **Show diffs, do not silently overwrite.**

**AGENTS.md placement rule (applies everywhere):**
Root `AGENTS.md` global constraints = **workflow + process rules only**: WIP=1, verification-before-done, branch/commit conventions, deploy approval gates.
Technical rules (language version, framework conventions, async/sync, cloud/infra rules, lint config, region) belong in **area AGENTS.md** — not root.

**The litmus test — apply to every candidate global rule:** imagine a developer working *only* in the area least related to this rule (e.g. a frontend dev for a backend rule). Is the rule still true, actionable, and binding for them, word for word? If not → it goes in the area file. "Applies to most areas" is not global. "Will matter once other areas exist" is not global.

**Beware dominant-area bias.** In most repos one area has the most code, the most git activity, and the most existing docs — the recon will naturally surface more rules from it, and it is tempting to promote them to root because they feel central. "Most evidence found" ≠ "global". A monorepo whose root AGENTS.md is 70% backend rules is a backend AGENTS.md wearing the wrong filename.

Expect root global constraints to be short — typically 3-7 workflow rules. If the list is longer, something area-specific has leaked in.

### If single-area repo

Generate in this order:

1. `AGENTS.md` — overview, stack with versions, hard constraints, working style, topic doc links, verification commands.
2. `Makefile` — replace each TODO with the real command. Test that each target actually works.
3. `docs/architecture.md` — module map, dependency rules, invariants. Cite file paths. The module map is the agent's navigation index: one line per module (or key file) stating **where responsibility lives** — e.g. `app/repo/fanout.py — Redis pub/sub publisher + subscriber`. Do NOT describe file contents (functions, signatures) — that rots within sessions; responsibility placement is stable.
4. `docs/testing.md` — test framework, conventions, verification command shapes.
5. `features.md` — propose 5-10 features. Each needs a real verification command. All `not_started` unless proven passing.
6. `DECISIONS.md` — pull design decisions from README, ADRs, prominent comments. Cite the source.
7. `QUALITY.md` — initial scoring of top-level modules. Default to B unless evidence says otherwise.
8. `PROGRESS.md` — current commit, build/test status, next steps = "review and adjust the harness files".

### If monorepo

Generate a tiered set. Order:

1. **Root `AGENTS.md`** — project overview (the whole system), global constraints that apply to ALL areas (git conventions, security rules, PR process, deploy rules), quick start (`make setup && make check`), and a routing table listing each area with its specific AGENTS.md path and when to load it.

   **Self-check before presenting:** go through each Global Constraint one by one and annotate (to yourself) which areas it binds. Any rule you cannot honestly tag with *every* area moves to the relevant area's AGENTS.md before you show the file. When presenting, add one line under the constraints list: "Each rule above passed the all-areas litmus test." If you moved rules during this check, say which and where they went — the user should not have to hunt for them.

2. **`<area>/AGENTS.md` per area** (e.g. `backend/AGENTS.md`, `frontend/AGENTS.md`, `infra/AGENTS.md`) — area-specific stack, constraints, and verification commands. Keep each under 150 lines. What belongs here: anything that only applies to this area (language version, framework conventions, area-specific lint rules, area-specific test commands).

   **Deferred area pattern:** If an area directory exists but has little or no code (or the recon summary shows it is not yet active), generate a "deferred with trigger" placeholder — not a half-filled file:
   - First line: `> **Status: intentionally deferred — not started yet.**`
   - Proposed stack inferred from repo (mark as "proposed")
   - Trigger block: the specific event that completes this file
   A placeholder that looks unfinished is worse than no placeholder.

3. **Root `Makefile`** — unified targets (`make setup`, `make check`) that delegate to area-specific targets, plus area targets (`make test-be`, `make test-fe`, `make lint-be`, etc.).

4. **`<area>/docs/architecture.md` per area** — module map and dependency rules for that area. Cite file paths. Module map format: one line per module/key file stating where responsibility lives (not file contents — those rot; responsibility placement is stable). This map is what lets future sessions find their touch zone without scanning the codebase.

5. **Root `docs/architecture.md`** — cross-area diagram only: how areas communicate (API contracts, message queues, shared schemas). Do not duplicate area-internal details.

6. **Root `features.md`** — all features, each with an `Area` column tagged `[BE]`, `[FE]`, `[BOTH]`, or the relevant area name. Features tagged `[BOTH]` require both areas' verification commands to pass before marking `passing`.

7. **Root `DECISIONS.md`**, `QUALITY.md`, `PROGRESS.md` — same as single-area, but QUALITY.md scores modules across all areas.

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
