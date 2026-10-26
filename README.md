# Harness Engineering Kit

A portable setup that makes AI coding agents (Claude Code, Codex, Cursor, …) reliable on real projects. Copy it into a repo, run one bootstrap prompt, and work.

## What it's built on (v2)

Models are now good at following short instructions and at reasoning about code. What they still can't do is guess what you want built, know the commands and constraints of your project, or tell honestly whether the work is done. The harness supplies exactly those three things and stays out of the way otherwise:

1. **What to build** — specs with concrete WHEN/THEN scenarios, managed with [OpenSpec](https://github.com/Fission-AI/OpenSpec), agreed before code is written.
2. **How this project works** — a short `AGENTS.md`: commands, where things live, the few constraints an agent would get wrong.
3. **Whether it's done** — a small number of tests derived from those scenarios, run at checkpoints; plus independent review for changes that matter.

Everything beyond that is weight. Long rule lists make current models over-apply rules, over-verify and over-use tools, so v2 is mostly deletions: fewer files, shorter prompts, guidance moved into skills that load only when relevant.

## Quick start

```bash
npm install -g @fission-ai/openspec@latest
cd your-project
openspec init
cp -r /path/to/this-kit/templates/. .
```

Open your agent in the project and paste `prompts/01-bootstrap.md`. Then, in Claude Code:

```
/opsx:propose add-something     write the change: proposal, scenarios, tasks — then review it
/opsx:apply                     build it: tests from the scenarios first
/handoff                        stopping mid-change? leave a note for next session
/opsx:archive                   done: the specs now describe the new behavior
```

## What's in the box

```
README.md                  you are here
GUIDE.md                   how to work with it: daily loop, testing, review, monorepos, teams, maintenance
docs/openspec.md           OpenSpec: install, commands, formats, brownfield adoption, pitfalls
templates/                 copy into your project
├── AGENTS.md              short: commands, map, how we work, constraints
├── CLAUDE.md              @AGENTS.md — Claude Code reads it from here
├── DECISIONS.md           project-wide decisions only
├── Makefile               setup / dev / test T=… / lint / check
├── docs/architecture.md   module map — where responsibility lives
├── lessons/INDEX.md       what past sessions learned the hard way — read on demand, evidence required
├── openspec/config.yaml   context + rules: testable scenarios, tests first, check once
└── .claude/
    ├── commands/handoff.md
    └── skills/            spec-driven-testing · agent-estimation · learn
prompts/                   paste into an agent
examples/fastapi-todo/     a filled-in project, mid-change
```

## Prompts

| Prompt | When |
|---|---|
| `01-bootstrap` | Once per project — fills the templates from the code or from your answers |
| `02-develop-idea` | You have an idea; think it through with unlimited questions and real alternatives, end in an OpenSpec change |
| `03-task-intake` | You've been handed a task: clarify, turn into a change, estimate, build, report |
| `04-acceptance-review` | Independent QA of a finished change, in a fresh session — behavior and test coverage |
| `05-scope-review` | Is anything missing — or is the scope already enough? |
| `06-maintain-harness` | Re-sync with the code and cut back — especially when a new model ships |
| `07-rewrite-prompt` | Improve any prompt, including the ones in your own application |

Most daily work needs none of them — the OpenSpec commands and `/handoff` cover it.

## Coming from v1?

`features.md`, `PROGRESS.md`, `TASK.md`, `QUALITY.md`, the session start/exit prompts and the checklists are gone — OpenSpec change folders carry that state now. See "Coming from v1" in GUIDE.md for the mapping and a gradual migration path.

## Sources

The 12 Harness Engineering lectures (continuity artifacts, WIP=1, feature lists, verification, clean handoff — the ideas survive, the files changed); Anthropic's prompting guidance for current Claude models and the "Harness design for long-running application development" engineering post (independent evaluators, stripping scaffolding as models improve); and OpenSpec.
