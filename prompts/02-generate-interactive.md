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

Ask me about:

- **Project purpose** — what is being built, in 1-2 sentences. Who uses it.
- **Stack** — language + version, framework, database, package manager, test framework, lint/typecheck tools. Be specific (versions matter).
- **Constraints I already know about** — e.g. "must use OAuth 2.0", "team prefers functional style", "no Docker in production".
- **Initial scope** — what are the first 3-5 features that need to be built? For each, what would "done" look like to me?

Group these into a single message with clear sub-questions. Wait for my answers before moving on.

## Phase 2 — Propose the harness

After my answers, propose updated versions of the template files. **Show each file's proposed content; do not write them until I approve each one.**

Order:

1. `AGENTS.md` — overview, stack, hard constraints, working style, verification commands. Stay under 200 lines.
2. `Makefile` — concrete commands for setup, dev, test, lint, typecheck, e2e, check. Use stack-appropriate tools. **If you are unsure what command to use, ask** — do not write a command you cannot defend.
3. `features.md` — break the initial scope into 3-5 features with executable verification commands. All `not_started`.
4. `docs/architecture.md` — propose a starting architecture (e.g. layered: api → service → repo) and the dependency rules. Confirm with me before committing.
5. `docs/testing.md` — adapt to the chosen test framework.
6. `DECISIONS.md` — log the decisions made during this Q&A (e.g. "chose FastAPI over Flask because ...") so they survive future sessions.
7. `QUALITY.md` — placeholder, since there are no modules yet. Note: "modules will be scored after first features land."
8. `PROGRESS.md` — current state = "harness bootstrapped, no features started", next steps = "verify bootstrap contract, then start F01".

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
