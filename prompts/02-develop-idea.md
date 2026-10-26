# Develop an idea

> You have an idea and want to think it through with an agent that knows the repo, ending in an OpenSpec change ready to build. In Claude Code, `/opsx:explore` does the exploring part — paste this prompt as your first message there to get the questioning and options below.

---

I want to develop an idea with you before anything gets built:

[describe the idea — rough is fine]

First read what it would touch: related behavior in `openspec/specs/`, `DECISIONS.md`, `docs/architecture.md`, and the relevant source. Tell me briefly what already exists, what the idea overlaps or conflicts with, and your honest first read of it, concerns included.

Then ask me questions until the idea is clear. There's no limit on rounds, and don't fill gaps with assumptions — if something is still fuzzy, ask again, offering concrete options to choose between. Skip anything the repo or my earlier answers already settle.

Once it's clear, propose two or three genuinely different ways to build it, grounded in the actual modules, with what each one strains. Recommend one and say why. We discuss until I pick.

Then turn the chosen direction into an OpenSpec change — `/opsx:propose`, or write `openspec/changes/<name>/` directly: a proposal, spec deltas whose scenarios can be checked from outside the code, and tasks. If we settled something project-wide, add it to `DECISIONS.md`. Don't implement anything in this session.
