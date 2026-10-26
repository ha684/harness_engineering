# OpenSpec guide

[OpenSpec](https://github.com/Fission-AI/OpenSpec) is the backbone of this kit's v2: it's where "what are we building, and how do we know it's done" lives. This guide covers how to use it and how it fits with the rest of the harness.

## Why spec-driven

When requirements live only in chat, every new session rebuilds them from memory and drifts a little. OpenSpec puts them in files, as **requirements with concrete scenarios**, and makes you agree on them *before* code is written. For agent work this does three things at once:

- **Defines done.** A change is done when its scenarios hold — not when the agent says so.
- **Gives tests their source.** Each WHEN/THEN scenario is a test waiting to be written (see the `spec-driven-testing` skill).
- **Carries state across sessions.** The change folder — proposal, spec deltas, task checklist, handoff note — is everything the next session needs.

It replaces three files from the v1 kit: `features.md` (now the change folders), `TASK.md` (a change folder *is* the brief), and `PROGRESS.md` (now the change's `tasks.md`).

## Install and initialize

```bash
npm install -g @fission-ai/openspec@latest     # or: brew install openspec
cd your-project
openspec init                                  # pick your tools — generates their slash commands
```

Then copy this kit's `templates/` in (it includes a pre-written `openspec/config.yaml`) and run `prompts/01-bootstrap.md`, which fills in the config's `context`.

`openspec init` generates commands for the assistants you select. In Claude Code they're `/opsx:<name>`; Cursor and Copilot use `/opsx-<name>`, Codex uses `$openspec-<name>`. Re-run `openspec update` after upgrading OpenSpec or changing your selection.

## Layout

```
openspec/
├── config.yaml                 # context + rules injected into everything OpenSpec generates
├── specs/                      # source of truth: how the system behaves now
│   └── <capability>/spec.md    # one folder per behavior area: auth/, tasks/, billing/ …
└── changes/                    # proposed changes, one folder each
    ├── <change-name>/
    │   ├── proposal.md         # why, and what's changing
    │   ├── design.md           # technical approach (optional)
    │   ├── tasks.md            # implementation checklist (+ our handoff note)
    │   └── specs/<capability>/spec.md   # deltas against the main specs
    └── archive/YYYY-MM-DD-<change-name>/   # finished changes, kept for history
```

## The commands

Run in your agent's chat:

| Command | What it does | When |
|---|---|---|
| `/opsx:explore` | Reads the code and thinks the idea through with you — no files written | You're not sure yet what to build |
| `/opsx:propose <name>` | Writes the change folder: proposal, spec deltas, design, tasks | You know what you want |
| `/opsx:apply` | Implements the change, working through `tasks.md` | After you've reviewed the proposal |
| `/opsx:archive` | Merges the spec deltas into `specs/` and moves the change to `archive/` | The change is done and checked |
| `/opsx:update` | Revises a change's proposal, specs, design and tasks so they stay consistent — never touches code, confirms each edit | Requirements shifted after proposing, even mid-implementation |
| `/opsx:sync` | Merges a change's spec deltas into `specs/` without archiving it | Rarely — a long-running change whose specs other changes need now. Archive offers to sync anyway |

All of them take an optional change name; without it, the agent infers the change from context.

An expanded profile (`openspec config profile`, then `openspec update`) adds more. The one worth having is `/opsx:verify`, which checks that the implementation matches the change's artifacts (completeness, correctness, coherence) without editing anything. `/opsx:new`, `/opsx:continue` and `/opsx:ff` split propose into smaller steps; `/opsx:bulk-archive` archives several changes at once; `/opsx:onboard` walks a newcomer through a real change.

Don't confuse the chat command `/opsx:update` (revise one change's plan) with the terminal command `openspec update` (regenerate OpenSpec's command files after upgrading or changing tools).

In the terminal:

```bash
openspec list               # active changes
openspec show <change>      # a change's details
openspec validate <change>  # check the spec format before you apply
openspec view               # interactive dashboard
```

## The file formats

**A main spec** (`openspec/specs/tasks/spec.md`):

```markdown
# Tasks Specification

## Purpose
Creating, listing and filtering a user's todo tasks.

## Requirements

### Requirement: List tasks
The system SHALL return the user's tasks newest first, 20 per page by default.

#### Scenario: Default page
- **WHEN** a client requests `GET /api/tasks` with 25 tasks stored
- **THEN** the response contains the 20 newest tasks and a link to the next page
```

Requirements use SHALL/MUST for hard requirements, SHOULD for recommended, MAY for optional. Every requirement needs at least one scenario.

**A delta spec** inside a change says what's being added, modified or removed:

```markdown
## ADDED Requirements

### Requirement: Filter tasks by status
The system SHALL return only tasks matching the `status` query parameter.

#### Scenario: Completed only
- **WHEN** a client requests `GET /api/tasks?status=completed`
- **THEN** only completed tasks are returned

## MODIFIED Requirements

### Requirement: List tasks
<the full new text of the requirement — not just the diff>
```

On archive, ADDED requirements are appended to the main spec, MODIFIED ones replace the original wholesale (so always write the complete requirement), and REMOVED ones are deleted.

**`tasks.md`** is a numbered checklist. This kit adds a `## Handoff` section at the bottom, written by `/handoff` at the end of each session:

```markdown
## 1. Status filter
- [x] 1.1 Tests for "completed only", "pending only", "no filter", "unknown value"
- [x] 1.2 Query parameter + validation
- [ ] 1.3 Repository filter
- [ ] 1.4 make check

## Handoff
Validation done and its tests pass. Next: 1.3 — `find_by_status` in app/repo/tasks.py.
The listing query has no tiebreak on created_at; the ordering test is flaky until 1.3 adds `id`.
```

**`design.md`** is optional. Write it when there's a genuine trade-off to record — which approach and why the others lost. Skip it for straightforward changes.

## A change from start to finish

1. **Explore** (optional). `/opsx:explore` — or `prompts/02-develop-idea.md` if you want unlimited questioning and alternatives laid out side by side.
2. **Propose.** `/opsx:propose add-status-filter`.
3. **Review the proposal — this is the most valuable step.** Read the scenarios. Are they what you actually want? Would each one catch a real bug if it failed? Is anything out of scope that should be in, or the reverse? Edit the files directly or ask for changes. Run `openspec validate add-status-filter`. Ten minutes here saves hours of building the wrong thing.
4. **Apply.** `/opsx:apply`. The tasks start with tests for the scenarios; the agent runs only the relevant tests while iterating.
5. **End of session** if the work isn't finished: `/handoff`. The next session runs `/opsx:apply` again and picks up from `tasks.md`.
6. **Check.** `make check` once, at the end. For changes that matter, run `prompts/04-acceptance-review.md` in a fresh session.
7. **Archive.** `/opsx:archive`. The spec now describes the new behavior.

## How this kit configures OpenSpec

`templates/openspec/config.yaml` sets project-wide rules that every generated artifact follows:

- **specs** — every requirement has a scenario that can be checked from outside the code, and the failure and edge cases that matter are covered.
- **tasks** — tests for a requirement's scenarios come first; `make check` runs once, last.
- **proposal** — changes stay small enough to build and review in one sitting, with explicit out-of-scope.
- **design** — only when there's a real trade-off.
- **apply / archive guidance** — iterate on targeted tests; record project-wide decisions in `DECISIONS.md` at archive.

The `context:` block is filled in by the bootstrap prompt: the product in one line, stack, test commands, key constraints. Keep it short — it's injected into every artifact.

## Existing codebases

**Spec only what you're about to change.** Don't back-fill specs for the whole codebase — it feels productive, takes days, and goes stale. Pick something small and real, a change you were going to make this week anyway, and run it through propose → apply → archive. The spec for that area now exists. Specs accumulate where the work actually happens, which is exactly where they're needed.

Run `/opsx:explore` first on unfamiliar code so the proposal fits the real architecture rather than a generic one.

## When you don't need a change at all

The test is not how big the edit is but whether it changes what the specs say:

| Work | OpenSpec change? |
|---|---|
| New behavior, or different behavior from what a spec describes — even a one-line edit | Yes. Otherwise the specs stop being true, and the next proposal builds on a false picture. |
| Bug fix that makes the code do what the spec already says | No — but add a test that would have caught the bug. If no scenario covered it, the spec had a gap; add the scenario in the next change that touches that area. |
| Refactor, rename, dependency bump, performance work with unchanged behavior | No. The existing scenario tests are what prove behavior didn't change. |
| Typo, copy text, config tweak, obviously low-risk edit | No. |

When unsure, a change costs a few minutes to propose; a spec that silently drifted from the code costs every later session.

## Sizing changes well

A good change is one coherent behavior shift that can be built and reviewed in a sitting — "filter tasks by status", not "task management v2". Signs it's too big: more than about 10 tasks, scenarios across several unrelated capabilities, or you can't review the proposal in ten minutes. Split it — several small changes beat one large one, both for the agent and for your review.

One change in progress at a time per person. Starting a second while the first is half-done is how half-done work accumulates.

## Teams

- The change folder is the unit of review. Open the PR with the proposal and spec deltas *before* `/opsx:apply`, and agree on the scenarios there; reviewing code against agreed scenarios is much faster than reviewing intent and code at once.
- To hand work to a contractor or another agent, hand them the change folder. It already contains the why, the acceptance criteria as scenarios, and the task list. They run `prompts/03-task-intake.md`.
- Archive promptly after merge, so `openspec/specs/` keeps describing what's actually deployed.

## Pitfalls

- **Skipping the proposal review.** The agent writes plausible scenarios; plausible isn't the same as what you want. This is your main point of control.
- **Untestable scenarios** — "the UI is intuitive", "performance is good". Rewrite them as observable outcomes ("search results appear within 300 ms for 10k tasks"), or accept that they're notes and not requirements.
- **MODIFIED with partial text.** Archive replaces the whole requirement; anything you left out is gone.
- **Changes that never get archived.** `openspec list` should be short. Stale changes mislead the next session about what's in progress.
- **Treating specs as documentation of the code.** They describe behavior the system must have. Implementation detail goes in `design.md` or nowhere.
