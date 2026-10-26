# Bootstrap a project

> Run once per project, after `openspec init` and copying `templates/` into the repo. Works for an empty repo and for an existing codebase. Paste as the first message.

---

Set up this repository so coding agents can work in it reliably. The kit's templates are in place with TODOs: `AGENTS.md`, `CLAUDE.md`, `DECISIONS.md`, `docs/architecture.md`, `Makefile`, `openspec/config.yaml`, and skills under `.claude/skills/`. Fill them from evidence — the code if there is any, my answers if there isn't.

Aim for a small harness. Everything you write is read by every future session, and current models do worse, not better, under long rule lists. Include only what an agent couldn't work out by reading the code. Don't write any feature code in this session.

## 1. Understand the project

**If there is code:** read the manifests, build and CI config, README, and a few representative files per area. Work out the stack, how to install, run and test it, the module layout, any conventions that aren't obvious from the code, and whether it's a monorepo. Run the install and test commands to see that they actually work.

**If the repo is empty or nearly so:** ask me what we're building and for whom, the stack per area, and any constraints I already know. Keep asking until it's clear; group questions so each round is easy to answer.

Then give me a short summary of what you found or understood, with anything uncertain called out. Wait for my confirmation before writing.

## 2. Fill the templates

Show each file before writing it.

- **`Makefile`** — real commands for `setup`, `dev`, `test`, `lint`, `check`. `make test T=<path>` must run a subset. Run each target to confirm it works.
- **`AGENTS.md`** — commands, where things live, constraints. A constraint earns a line only if an agent would plausibly get it wrong without being told; give it a reason, and point to the tool that enforces it when one does. Stay under ~60 lines.
  - *Monorepo:* the root file holds only what's true in every area. Check each root line against the area least related to it — if it isn't true and useful there, it belongs in that area's `AGENTS.md`. The area you'll build first will dominate the conversation; that doesn't make its rules global. An area that hasn't started gets a three-line placeholder: not started yet, proposed stack, fill in when the first change lands there.
- **`CLAUDE.md`** — leave as `@AGENTS.md`. In a monorepo, add `<area>/CLAUDE.md` containing `@AGENTS.md` next to each area's `AGENTS.md`.
- **`docs/architecture.md`** — the module map at the "where responsibility lives" level, plus dependency boundaries.
- **`openspec/config.yaml`** — fill `context` with the product in one line, the stack, the test commands, and the constraints from `AGENTS.md`. Keep the `rules` section as it is.
- **`DECISIONS.md`** — decisions actually made, with their reasons, from code evidence, existing docs or our conversation. An empty file is fine.
- **`lessons/INDEX.md`** — leave it empty. Lessons come from evidence in real sessions; don't seed it with general advice.

Don't write specs for existing code. OpenSpec specs accumulate as real changes are archived; back-filling them is busywork that goes stale.

## 3. Confirm it works

- `make setup` succeeds on a clean checkout and `make check` passes. For a new project, one real smoke test is enough to prove the toolchain.
- An agent reading only the repo could answer: what is this, how do I run it, how do I check my work.

Report what passed and what didn't, as it actually happened. Then suggest a first change — small and real — to run through `/opsx:propose`.
