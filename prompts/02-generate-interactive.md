# Prompt: Generate harness files via interactive Q&A

> **How to use:** Open an agent in a (mostly) empty project directory that has the template files copied in. Paste the prompt below as your first message. The agent will ask you ~10 structured questions and then fill the templates from your answers.

---

You are bootstrapping the harness engineering layer for a brand-new project. The template files are present but contain TODO placeholders. There is no existing code (or very little) to scan, so you cannot infer conventions from the repository — you must ask me.

## Operating principles

1. **Ask, don't guess.** Anything you do not have explicit input on goes into "Open Questions" in `PROGRESS.md`, not into the harness files.
2. **One question at a time, or grouped logically.** Do not dump 20 questions in one message — that is hard to answer well. Group related questions (e.g. all "tech stack" questions together).
3. **Use defaults sparingly and announce them.** If you propose a default ("I'll assume pytest unless you say otherwise"), say so explicitly and wait for confirmation.
4. **Stop and confirm before writing.** Never write a file silently. Always show the proposed content and wait for approval.

## Phase 1 — Project shape

Ask me about the following. Group into a single message with clear sub-questions. Wait for my answers before moving on.

- **Project purpose** — what is being built, in 1-2 sentences. Who uses it.
- **Repo structure** — is this a single-area project (one language, one framework) or a **monorepo** with multiple distinct areas (e.g. backend + frontend, or backend + frontend + infra)? If monorepo, list each area and its rough stack. This is the most important structural question — the rest of Phase 2 branches based on this.
- **Stack per area** — language + version, framework, database, package manager, test framework, lint/typecheck tools. Be specific (versions matter). If monorepo, answer per area.
- **Constraints I already know about** — e.g. "must use OAuth 2.0", "team prefers functional style", "no Docker in production", "infra changes require human approval". If some constraints apply only to one area, say which.
- **Initial scope** — what are the first 3-5 features to build? For each: which area(s) does it touch, and what does "done" look like?

Wait for my answers before moving on.

## Phase 2 — Propose the harness

After my answers, propose files in the order below. **Show each file's proposed content; do not write until I approve.**

### If single-area

1. `AGENTS.md` — overview, stack, hard constraints, working style, verification commands. Under 200 lines.
2. `Makefile` — concrete commands: setup, dev, test, lint, typecheck, e2e, check. Ask if unsure — never invent a command.
3. `features.md` — 3-5 features with verification commands. All `not_started`.
4. `docs/architecture.md` — starting architecture + dependency rules. Confirm before writing.
5. `docs/testing.md` — adapted to the chosen test framework.
6. `DECISIONS.md` — decisions made during this Q&A with reasons.
7. `QUALITY.md` — placeholder. Note: "modules scored after first features land."
8. `PROGRESS.md` — state = "bootstrapped, no features started".

### If monorepo

Generate in this order:

1. **Root `AGENTS.md`** — whole-system overview, global constraints (apply to ALL areas), `make setup && make check`, and a routing table:
   ```
   ## Area routing
   - Working in backend/ → also read backend/AGENTS.md
   - Working in frontend/ → also read frontend/AGENTS.md
   - Working in infra/ → also read infra/AGENTS.md
   - Cross-area change → read all relevant area AGENTS.md files
   ```

2. **`<area>/AGENTS.md` per area** — area-specific stack, constraints, verification commands. Under 150 lines each. Only rules that differ from or add to the root.

3. **Root `Makefile`** — unified targets (`make setup`, `make check`) plus area-specific targets (`make test-be`, `make test-fe`, `make lint-be`, `make lint-fe`, etc.).

4. **`<area>/docs/architecture.md` per area** — that area's module map and layer rules.

5. **Root `features.md`** — all features with an `Area` column: `[BE]`, `[FE]`, `[BOTH]`, or area name. `[BOTH]` features only reach `passing` when BOTH areas' verification commands pass.

6. **Root `DECISIONS.md`** — decisions from this Q&A. Mark area-scoped decisions with the area name.

7. **Root `QUALITY.md`** — placeholder, will score per-module across areas once features land.

8. **Root `PROGRESS.md`** — state = "bootstrapped, no features started".

## Phase 3 — Bootstrap contract verification

Before declaring done, verify the four conditions from lecture 06:

- [ ] `make setup` runs cleanly (run it; if it fails, fix the Makefile before declaring done)
- [ ] `make test` runs and passes at least one test (write a trivial test if needed — e.g. `def test_smoke(): assert 1 + 1 == 2` — to prove the framework works)
- [ ] A new agent session can answer the cold-start questions using only the files in this repo
- [ ] `features.md` has at least 3 tasks with real verification commands

Report any failures. **Do not invent passing tests** — if you cannot make `make test` pass with a real test, leave it as a known gap and add it to `PROGRESS.md`'s "Open Questions".

## What to avoid

- **No code beyond the trivial smoke test.** This prompt is for harness bootstrap only. Feature implementation comes in subsequent sessions, after the bootstrap contract is verified (lecture 06: do not mix initialization and implementation).
- **No assumed conventions.** If I did not specify, ask. Common pitfalls: error handling style, async vs sync, ORM choice, file structure.
- **No filling in `DECISIONS.md` with platitudes.** Only log decisions that were actually made and have a real reason.

## Output format

For each phase:

1. Ask your questions clearly, grouped, with brief context where helpful.
2. Wait for my answers.
3. Propose the next file's content in a code block, with a 1-2 sentence rationale.
4. Wait for approval before writing.

Begin with Phase 1.
