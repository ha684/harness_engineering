# Guide

How to run a project with this kit. README.md says what's in the box; this says how to work with it.

## How the pieces fit

| Piece | Answers | Who writes it |
|---|---|---|
| `AGENTS.md` (+ `CLAUDE.md` → `@AGENTS.md`) | How do I run and check things here? What would I get wrong? | You, rarely |
| `openspec/specs/` | What must the system do? | Grows from archived changes |
| `openspec/changes/<name>/` | What are we changing now, how far along is it? | Agent proposes, you review |
| Tests | Does it actually do that? | Agent, from the scenarios |
| `docs/architecture.md` | Where does this change belong? | Agent keeps the map current |
| `DECISIONS.md` | Why is it built this way? | Both, only for project-wide choices |
| `lessons/` | What tripped us up before? — opened only when relevant | Agent, only with evidence |
| `.claude/skills/` | How do I do X here? — loaded only when X comes up | You, occasionally |

The design rule behind all of it: **give the agent facts it can't infer, not behavior it already has.** Models now follow short instructions well and reason about code better than a rulebook can describe; long rule lists make them over-apply rules, over-verify and over-use tools. So the kit keeps standing instructions to a minimum and puts everything else where it's only read when relevant — specs per change, skills on demand, tests as executable checks.

## Setting up a project

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init                       # choose your agent(s)
cp -r /path/to/kit/templates/. .    # AGENTS.md, CLAUDE.md, DECISIONS.md, Makefile, docs/, openspec/config.yaml, .claude/
```

Open the agent in the project and paste `prompts/01-bootstrap.md`. It reads the code (or asks you, on an empty repo), fills the templates, and checks that the commands work. Review what it writes — especially `AGENTS.md`: if a line wouldn't change what a competent engineer does, delete it.

The project is ready when:

- `make setup` works from a fresh clone and `make check` passes.
- An agent reading only the repo can say what this is, how to run it, and how to check its work.

Then start your first change. Don't write specs for existing code up front; they accumulate from real changes.

## The daily loop

```
/opsx:explore            think it through            (optional — or prompts/02-develop-idea.md)
/opsx:propose <name>     proposal + scenarios + tasks
  → review the scenarios                             (your main point of control)
/opsx:update             requirements changed? revise the plan, not the code
/opsx:apply              tests from scenarios, then code
/handoff                 if stopping mid-change
make check               once, when the change is complete
prompts/04 in a fresh session                        (for changes that matter)
/opsx:archive            specs now describe the new behavior
```

**Reviewing the proposal is where your time pays off most.** The agent writes plausible scenarios; you decide whether they're the right ones. Ask of each: is this what I want, and would this test catch a real bug? Edit freely.

**Across sessions** there's nothing to paste at the start. `AGENTS.md` tells the agent to read the active change's `tasks.md`, whose `## Handoff` note says where things stand. Current models are good at reconstructing state from the filesystem and git; the handoff note covers what they can't see — what was surprising, what's next, what's waiting on you. End a session mid-change with `/handoff` (in other agents, paste the content of `templates/.claude/commands/handoff.md`).

**One change at a time.** Things you notice outside the change go in the handoff note as follow-ups, not into the diff.

**Not everything needs a change.** The loop is for work that changes what the specs say — new or different behavior, however small the edit. Bug fixes that restore specified behavior, refactors, dependency bumps and obvious low-risk edits go straight to code; a bug fix still gets a test that would have caught it. Details in `docs/openspec.md` → "When you don't need a change at all".

## Testing

The full approach is in the `spec-driven-testing` skill (`templates/.claude/skills/spec-driven-testing/SKILL.md`), which the agent loads whenever it works on tests. In short:

- **Tests come from spec scenarios.** One focused test per scenario that a bug could plausibly break, named after the scenario. No scenario, no test — and a behavior worth testing that has no scenario means the spec is missing something.
- **Few and hard over many and easy.** Effort goes where bugs live: failure paths, edge values, ordering, concurrency, the seam between components. Not getters, mappings, framework behavior, or one-test-per-function.
- **Behavior from the outside.** Through HTTP, CLI, UI or the public API, with real dependencies where they're cheap. No assertions on internal calls or mocks.
- **Test first.** Write the scenario's test, see it fail for the right reason, then implement.
- **Run at checkpoints, not after every edit.** Narrow tests while iterating (`make test T=…`), the full `make check` once when the change is complete.

If tests in an existing project don't match this — too many, too brittle, testing implementation — leave them unless they're slowing you down; then propose a change that deletes or rewrites the worst offenders, with scenarios for what they were actually guarding.

## Review

Two different questions, two tools:

- **Is the code good?** Claude Code's built-in `/code-review` (and `/security-review`) on the diff.
- **Does it do what the spec says?** `prompts/04-acceptance-review.md` in a fresh session. It exercises each scenario through the running app, checks for verification gaps — changed behavior with no scenario, scenarios with no test, tests that would pass even if the behavior broke — and reports every issue with severity and confidence.

The fresh session matters: an agent reviewing its own work in the same context is reliably generous; one with clean context isn't. Use the acceptance review where the cost of a miss is high — user-facing flows, data changes, anything crossing components. Skip it for small internal changes; the scenario tests already cover those.

## Monorepos

- Root `AGENTS.md` holds only what's true in every area: shared commands, how we work. Each area gets its own short `AGENTS.md` with its stack, commands and constraints, plus a `CLAUDE.md` containing `@AGENTS.md` so Claude Code loads it when working there.
- Test every root line against the area furthest from it. A backend async rule in root `AGENTS.md` is wrong even if the backend is all you've built so far.
- OpenSpec capabilities can follow areas (`specs/api-tasks/`, `specs/web-tasks/`) or features spanning them — whichever matches how you think about behavior. A change touching backend and frontend is fine as one change if it's one behavior; split it if it's two.
- Per-area make targets (`test-be`, `lint-fe`, …), with `make check` running all of them.

## Teams and outsourcing

- **The change folder is the unit of work and review.** Agree on the proposal and scenarios in a PR before applying; then review code against agreed scenarios.
- **Handing work out:** give the contractor or the other agent the change folder plus repo access. It carries the why, the acceptance criteria as scenarios, and the tasks — no separate brief needed.
- **Receiving work:** `prompts/03-task-intake.md` turns a ticket into a change through Q&A, estimates it with the `agent-estimation` skill, and builds it once you approve.
- **Accepting delivered work:** `prompts/04-acceptance-review.md`, then archive.
- `DECISIONS.md` changes go through review like code; it's shared truth.

## Lessons

Sessions learn things the hard way — a library that behaves unexpectedly, a query that's nondeterministic, a test setup that hides a bug — and without somewhere to put them, the next session learns them again. `lessons/` is that place. The idea comes from Google Research's Harness² paper, where a library of evidence-backed lessons was among the largest contributors to agent performance.

Two rules keep it from turning into another rulebook:

- **On demand, not always loaded.** `AGENTS.md` points at `lessons/INDEX.md`; the agent opens only the entries that match the work in front of it.
- **Evidence or nothing.** A lesson needs a concrete failure, the specific change that fixed it, and confirmation that it worked. `/handoff` and `/opsx:archive` record lessons when a session earned one; hunches and preferences don't qualify.

A lesson isn't a decision: `DECISIONS.md` says why the project is built a certain way; a lesson says what will bite you if you don't know it. When the code a lesson describes is removed, or a test starts enforcing it, delete the lesson — `prompts/06` checks for this.

## Skills in the kit

Skills are loaded only when relevant, which makes them the right home for guidance that matters sometimes — instead of `AGENTS.md`, which is read every time. The templates ship three in `.claude/skills/` (Claude Code's location; other agents that support skills have their own directory — copy the folders there):

| Skill | Used when |
|---|---|
| `spec-driven-testing` | Writing, choosing or running tests |
| `agent-estimation` | Estimating or scoping work — counts tool-call rounds, not human days, and includes comprehension, testing and review |
| `learn` | You want to understand something rather than get it done — tutoring mode |

Add a skill when you find yourself repeating the same guidance across sessions. Keep `SKILL.md` as the file name, and make the `description` say precisely when it applies — that's what decides whether it loads.

## Keeping the harness small

Every standing instruction costs attention in every session, and outdated ones actively hurt. When you're tempted to add a rule, place it as far down this list as it will go:

1. **Tooling enforces it** — linter rule, type check, formatter, pre-commit hook. Best: no prose at all.
2. **A test enforces it** — a spec scenario with a test.
3. **It applies only to some work** — a skill, or the relevant change's design.
4. **It applies to every session, and an agent would get it wrong otherwise** — one line in `AGENTS.md`, with its reason.
5. **None of the above** — don't write it down.

Run `prompts/06-maintain-harness.md` when code has moved without the harness (merged branches, teammates, hotfixes), when sessions start to feel heavy, and **whenever a new model ships**. That last one matters most: each model generation makes some instructions unnecessary, and instructions written to push an older model ("CRITICAL: always…", "double-check before…") make newer ones overdo it. The harness should get smaller over time.

`prompts/07-rewrite-prompt.md` applies the same thinking to the prompts in your own application.

## When things go wrong

| Symptom | Usually means | Fix |
|---|---|---|
| Built the wrong thing | Scenarios didn't capture what you wanted | Spend longer on proposal review; add the missing scenario |
| Said done, isn't | No scenario covers what broke, or tests check internals | Add the scenario + an outside-in test; run acceptance review |
| Redoes or forgets work across sessions | No handoff, or the change was never archived | `/handoff` before stopping; archive finished changes |
| Repeats the same mistake in later sessions | What was learned stayed in a chat | Record a lesson with its evidence |
| Ignores a constraint | It's buried in a long file, or has no reason attached | Move it to tooling or a test; if it must be prose, one line with a why |
| Overdoes things — extra checks, extra files, extra tests | Standing instructions pushing too hard | `prompts/06` — cut rules, especially old emphatic ones |
| Tests slow everything down | Full suite after every edit, or too many tests | Targeted tests while iterating; prune tests that don't map to scenarios |

## Coming from v1

| v1 | v2 |
|---|---|
| `features.md` | `openspec/changes/` (in progress) and `openspec/specs/` (delivered) |
| `PROGRESS.md` | The active change's `tasks.md` + `## Handoff`; git history |
| `TASK.md`, prompts 05/06 | The change folder; `prompts/03-task-intake.md` |
| `QUALITY.md` | Dropped — review and failing scenarios surface quality issues when they matter |
| Session start/exit prompts | Nothing at start; `/handoff` at end |
| `docs/testing.md`, three-layer verify script | `spec-driven-testing` skill; `make check` once per change |
| Prompts 09, 10, 11 | `/opsx:explore` or `prompts/02`; `prompts/06` |
| Checklists | Folded into this guide |

Migrating a live project: you don't have to do it in one go. Install OpenSpec, run `prompts/06-maintain-harness.md` to cut `AGENTS.md` down, and start the *next* feature as an OpenSpec change. Move any still-relevant `features.md` items into `DECISIONS.md` → "Not doing" or into new changes as you get to them; then delete the old state files.
