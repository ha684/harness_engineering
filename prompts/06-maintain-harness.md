# Maintain the harness

> Run when the harness has drifted or grown: code changed outside agent sessions (merged branches, teammates, hotfixes), sessions start feeling heavy, or a new model has shipped. Optionally give a starting point: "changes since `<commit>`" or "since `<date>`". No code changes in this session — only harness files.

---

Bring this repo's harness back in line with the code and cut it back to what earns its place. The harness is `AGENTS.md` (and area `AGENTS.md` files), `docs/architecture.md`, `DECISIONS.md`, `lessons/`, `openspec/config.yaml`, `.claude/` commands and skills, and the state of `openspec/changes/`.

The usual way this kind of session fails is timidity: it tightens a few phrases and leaves the files as heavy as before. The targets below are the goal, not a suggestion. Cutting is safe — git keeps everything, and archived OpenSpec changes keep per-change history.

## 1. Find what drifted

Look at what changed in the code (`git log` / `git diff` from the starting point, or the last few weeks if none was given) and check:

- Commands in `AGENTS.md` and the `Makefile` still exist and work. Run them.
- The module map in `docs/architecture.md` matches the files that exist now.
- Specs in `openspec/specs/` that the code now contradicts. Flag these — whether the code or the spec is right is my call.
- Technical choices in the code with no `DECISIONS.md` entry. Ask me for the reason rather than inventing one.
- Changes in `openspec/changes/` that are finished but not archived, or abandoned.

## 2. Find what no longer earns its place

Targets: root `AGENTS.md` under ~60 lines, area files under ~40, `DECISIONS.md` about one screen of live entries.

- An `AGENTS.md` line goes if a linter, type check, test or spec scenario already enforces it, if an agent would do the right thing anyway, or if it describes something the code makes obvious.
- A `DECISIONS.md` entry goes if it's been replaced, or no longer constrains anything being built.
- A lesson goes if the code it describes is gone, a test or linter now enforces it, or another lesson says the same thing. A lesson about general agent behavior (planning, checking work, tool use) rather than this project is the first to go stale when a model ships — check those hardest. A lesson that matters in nearly every session may deserve promotion to one line in `AGENTS.md`; that should be rare.
- A `config.yaml` context line goes if it repeats `AGENTS.md` without helping proposals.
- Stale handoff notes in active changes get cut to what's still true.

**If a new model has shipped**, also list instructions that exist to compensate for older models' habits: emphatic MUST/CRITICAL wording, "double-check" or "verify before responding" steps, bans on formatting, step-by-step reasoning scripts, rules telling the agent to use a tool it would use anyway. Current models over-apply these. Propose removing them; the user can run a normal task afterwards to confirm nothing got worse.

## 3. Plan, then apply

Show a plan before editing:

```
| File | Lines now → after | Changes |
Flags for you: <contradictions, missing reasons, anything ambiguous>
```

If a file's "after" misses its target, say why for that file. After I approve, apply exactly the plan, re-run the commands you touched, and report before/after line counts. Don't commit.
