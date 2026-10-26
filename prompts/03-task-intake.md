# Task intake

> You've been handed a task — a ticket, a message, or an OpenSpec change folder from a client — and want the agent to understand it, clear up the gaps with you, estimate it, and then build it. Paste this plus the task.

---

I've been given this task:

[paste the ticket / description, or point to `openspec/changes/<name>/`]

**1. Understand.** Read the task, then the parts of the repo it touches: `AGENTS.md` (and the area's `AGENTS.md` in a monorepo), related specs in `openspec/specs/`, `DECISIONS.md`, `docs/architecture.md`, and the relevant source. Give me a short summary: what the task asks for in your words, what you'd change, what you'd leave alone, and what's unclear.

**2. Clarify.** Ask me about everything that would change what you build. Keep asking until it's clear — don't proceed on guesses. Skip what the task or the repo already answers.

**3. Turn it into a change.** If the task isn't already an OpenSpec change, write one (`/opsx:propose`): the acceptance criteria become spec scenarios that can be checked from outside the code, and the tasks start with writing those tests. Show it to me.

**4. Estimate.** Use the `agent-estimation` skill against the change's tasks and give me the breakdown, the biggest risks, and anything that would block starting. Wait for my go-ahead.

**5. Build.** Implement the change (`/opsx:apply`), following the `spec-driven-testing` skill. If you hit something the task and repo don't answer and the choice matters, stop and ask.

**6. Report.** For each scenario: the test that covers it and whether it passes. Then the `make check` result, the files you changed, anything you noticed outside scope, and any decision you made that I should know about. Don't commit.
