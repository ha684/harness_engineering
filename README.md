# Harness Engineering Template

A portable, tool-agnostic harness template for AI coding agents (Claude Code, Codex, Cursor).

This repository is **not a project** — it is a kit you copy into projects. It packages the five-subsystem harness model from the lectures into reusable templates, generator prompts, and a worked example so you can stand up a reliable agent harness in any new repo in under 30 minutes.

## The five subsystems (recap)

| Subsystem | Question it answers | Files in this kit |
|---|---|---|
| **Instruction** | What is this project, what are the rules? | `AGENTS.md`, `docs/*.md` |
| **Tool** | What can the agent run? | `Makefile`, `scripts/` |
| **Environment** | How is the runtime reproducible? | lockfiles, `Makefile setup` target |
| **State** | What is done, in progress, decided? | `PROGRESS.md`, `DECISIONS.md`, `features.md` |
| **Feedback** | How do we know it actually works? | `scripts/verify.sh`, `Makefile check` |

Missing any one of these is like a kitchen with no stove, or no quality-check window — you can still cook, but it will be awkward and unreliable.

## What is in this repo

```
harness_engineering/
├── README.md                 # You are here
├── GUIDE.md                  # Full workflow, including product-dev and outsource models
├── templates/                # COPY THESE into your new project
│   ├── AGENTS.md             # Routing entry file (50-200 lines)
│   ├── PROGRESS.md           # Cross-session state (single-person / feature branch)
│   ├── DECISIONS.md          # Design decision log
│   ├── features.md           # Feature list with state machine
│   ├── TASK.md               # Outsource contract (one task handed to a contractor)
│   ├── QUALITY.md            # Per-module quality tracker
│   ├── Makefile              # Standardized commands
│   ├── docs/                 # Topic docs (loaded on demand)
│   ├── scripts/              # Verification + session-exit checks
│   └── .claude/commands/     # Claude Code slash commands (/session-start, /session-exit)
├── prompts/                  # PASTE THESE into an agent to generate filled files
│   ├── 01-generate-from-repo.md     # Existing projects (agent scans code)
│   ├── 02-generate-interactive.md   # Greenfield (agent asks you)
│   ├── 03-session-start.md          # Clock-in routine
│   ├── 04-session-exit.md           # Clock-out (clean handoff)
│   ├── 05-generate-task-brief.md    # Generate a TASK.md for outsourcing (client side)
│   └── 06-task-intake.md            # Receive + plan + implement + verify a task (contractor side)
├── examples/
│   └── fastapi-todo/         # Fully filled-in worked example to study
│       ├── AGENTS.md, PROGRESS.md, DECISIONS.md, features.md, QUALITY.md, Makefile
│       └── TASK-F04-example.md      # What a good TASK.md looks like when filled
└── checklists/               # Quick-reference checklists
    ├── bootstrap-contract.md # Lecture 06: four init conditions
    ├── cold-start-test.md    # Lecture 03: five cold-start questions
    ├── session-exit.md       # Lecture 12: five clean-state dimensions
    └── task-handoff.md       # Outsource model: pre-delivery + post-review checks
```

## Quick start (60 seconds)

For a brand-new project:

```bash
# 1. Copy templates into your project root
cp -r templates/* /path/to/your-project/
cp -r templates/.* /path/to/your-project/ 2>/dev/null || true

# 2. Open an agent in that project and paste prompts/02-generate-interactive.md
#    The agent will ask you ~10 questions and fill in AGENTS.md, features.md, etc.

# 3. Verify the bootstrap contract (checklists/bootstrap-contract.md):
#    - make setup works
#    - make test runs at least one passing test
#    - a new session can answer "how do I run / test / continue this?"
```

For an existing project:

```bash
# 1. Copy templates into your project root (same as above)

# 2. Paste prompts/01-generate-from-repo.md into an agent with repo access.
#    It will scan your code and propose filled-in versions of every template.

# 3. Review, adjust, commit.
```

## Read GUIDE.md next

`GUIDE.md` walks through the full workflow: how to onboard a new project, how to run a session start-to-finish, what to do when something fails, and how to evolve the harness over time.

## Two team models

`GUIDE.md` covers three operating modes in detail:

| Mode | Key files | When |
|---|---|---|
| **Single-person / solo agent** | AGENTS.md, PROGRESS.md, features.md | Personal projects, solo sessions |
| **Product development** | AGENTS.md on main, SESSION.md on branch, features.md as state machine | Multi-person team, continuous sprints |
| **Outsourcing / task-based** | AGENTS.md + DECISIONS.md + TASK.md delivered per task | Contractors, freelancers, isolated agent sessions |

The instruction subsystem (AGENTS.md, docs/, DECISIONS.md) is **universal across all three modes**. Only the state subsystem (PROGRESS/SESSION/TASK) changes.

## Source lectures

This template synthesizes:
- Lecture 02 — five-subsystem harness model
- Lecture 03 — repo as single source of truth + ACID state
- Lecture 04 — instruction file splitting (entry file as router)
- Lecture 05 — cross-session continuity artifacts
- Lecture 06 — dedicated initialization phase + bootstrap contract
- Lecture 07 — WIP=1 scope control
- Lecture 08 — feature list as harness primitive
- Lecture 09 — three-layer termination validation
- Lecture 10 — end-to-end verification + architectural rules as executable checks
- Lecture 11 — runtime + process observability (sprint contract, evaluator rubric)
- Lecture 12 — clean handoff at session exit
