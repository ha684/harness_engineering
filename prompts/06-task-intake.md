# Prompt: Task intake (contractor / assignee side)

> **How to use:** You just received a task package (TASK.md + AGENTS.md + DECISIONS.md + relevant docs).
> Paste this prompt as your first message. The agent will read everything, ask you clarifying
> questions, propose a plan with an estimate, wait for your go-ahead, implement, then
> walk you through a completion Q&A before declaring done.
>
> You do NOT need a full project harness set up. The only required files are TASK.md and AGENTS.md.

---

You have been handed a task. Your job is to complete it correctly and return evidence of completion.
Work in four phases. Do not skip phases or merge them. Each phase ends with a pause for human input.

---

## Phase 1 — Read and understand

Read the following files **in this order**. Do not skim.

1. `TASK.md` — the contract. Read every section: scope, out-of-scope, acceptance criteria, verification command, context pointers. Note the area tag if present (`[BE]`, `[FE]`, `[BOTH]`).
2. **Root `AGENTS.md`** — global non-negotiable rules. Apply to all your work.
3. **Area-specific `AGENTS.md`** — if TASK.md has an area tag or if the scope files live under an area directory (e.g. `backend/`, `frontend/`), check for and read that area's AGENTS.md (e.g. `backend/AGENTS.md`). These contain stack-specific constraints that override or extend the root. If no area-specific file exists, continue.
4. `DECISIONS.md` — read only the entries referenced in TASK.md "Context — decisions affecting this task".
5. Source files listed in TASK.md "Relevant files to read first" — read fully.
6. Source files in TASK.md "Scope" — skim to understand current state.

After reading, produce a structured **understanding summary**:

```
## Understanding summary

Task: [one sentence]

Acceptance criteria (restated in your own words):
  1. ...
  2. ...

Files I will change:
  - path/to/file.py — what I will do here

Files I will NOT change (out-of-scope confirmation):
  - ...

Verification command: [copy from TASK.md]

Constraints I must respect:
  - [list from AGENTS.md and DECISIONS.md that apply]

Things I am NOT sure about:
  - [honest list — see Phase 2]
```

**Stop here. Show the summary. Do not proceed to Phase 2 until told to.**

---

## Phase 2 — Clarifying Q&A

Based on your understanding summary, ask every question you need answered before you can write a confident implementation plan.

Rules for questions:
- Ask only things that will change your implementation if answered differently.
- Do not ask about things already clearly specified in TASK.md or AGENTS.md.
- If a question is about a hard constraint you missed, note it explicitly ("I see AGENTS.md says X — does that apply here too?").
- Group related questions together. Maximum 2 rounds of Q&A — if you still have questions after round 2, note them as assumptions you are making and flag them in the plan.

After the human answers, incorporate the answers into your understanding before Phase 3.

**Stop here. Wait for answers. Do not proceed to Phase 3 until the human responds.**

---

## Phase 3 — Plan + estimate

Produce an **implementation plan** and an **estimate**. Do not write any code yet.

### Implementation plan

```
## Implementation plan

Step 1: [file or concern]
  - What: [specific change]
  - Why: [which acceptance criterion this serves]
  - Risk: [anything that could go wrong here]

Step 2: ...

Step N: Run verification
  - Command: [from TASK.md]
  - Expected output: [what passing looks like]
```

Order steps so that the verification command can be run incrementally — each step should leave the code in a runnable state (no half-baked intermediate states that break the build).

### Estimate

```
## Estimate

Complexity: [Low / Medium / High]
Reason: [1-2 sentences — what makes it easy or hard]

Time estimate: [e.g. "1-2 hours", "half a day"]
Confidence: [High / Medium / Low]
Main uncertainty: [what could make it take longer]

Blockers (if any): [things that would stop work before you can start]
```

**Stop here. Show plan + estimate. Do not write code until the human approves.**

If the human says "looks good" or equivalent, proceed to Phase 4.
If they request changes to the plan, revise and re-show before proceeding.

---

## Phase 4 — Implementation

Now implement, following your approved plan step by step.

Rules:
- **WIP within this task = 1.** Complete one step fully before starting the next.
- **No out-of-scope changes.** If you spot something to fix that is outside TASK.md scope, write it as a note in TASK.md "Evidence → Notes" and do not touch it.
- **No "looks fine" declarations.** After each step that produces testable output, run a quick smoke check before moving to the next step.
- **Follow AGENTS.md constraints without exception.** If a constraint conflicts with the cleanest implementation, follow the constraint and note the tension in your evidence.
- **Ask before guessing.** If you encounter a situation not covered by TASK.md or AGENTS.md and the decision is non-trivial, stop and ask. Do not silently pick an option.

After all steps are complete, run the verification command. If it fails:
- Diagnose the failure (do not guess — read the output)
- Fix the root cause
- Re-run
- Do not move to Phase 5 until the verification command exits 0

---

## Phase 5 — Completion Q&A

Walk through each acceptance criterion from TASK.md one by one and confirm it is met.

Format:

```
## Completion check

Criterion 1: [restate from TASK.md]
  Status: PASS
  Evidence: [what you ran / what you observed]

Criterion 2: ...
  Status: PASS / FAIL
  Evidence: ...
```

If any criterion is FAIL, go back to Phase 4 and fix it. Do not proceed with a FAIL in this list.

Then run the **full check** (`make check` or equivalent from AGENTS.md) and confirm it passes.

Then fill in TASK.md "Evidence" section:

```markdown
## Evidence

- Completion date: [today]
- Commit hash: [run git log -1 --oneline]
- Verification command output:
  [paste last 20-30 lines — include test count summary, not just "ok"]
- make check status: [passing / N failures]
- Notes: [anything the client should know:
    - edge cases encountered
    - minor decisions made (and why)
    - deferred items you noticed but did not touch
    - assumptions you made in Phase 2 that were unconfirmed]
```

**Stop here. Show the completed TASK.md Evidence section to the human for review before considering the task done.**

---

## Final delivery

After human confirms:

1. Confirm the diff contains only files in TASK.md "Scope".
2. Confirm no debug artifacts (`console.log`, `breakpoint()`, temp files, commented-out blocks).
3. Summarize for the human in 3-5 bullet points:
   - What was implemented
   - What was explicitly NOT done (out of scope, deferred)
   - Any decisions you made that the client should be aware of
   - Any risks or follow-up items

The task is done when:
- [ ] Verification command exits 0
- [ ] `make check` exits 0
- [ ] TASK.md Evidence section is filled
- [ ] Human has seen and acknowledged the completion summary

---

## If you get stuck

If at any point you cannot proceed without information not available in the provided files:

1. **Stop immediately** — do not guess or invent a plausible-sounding answer.
2. State clearly: "Blocked — I need [specific information] to proceed. This is not in TASK.md or AGENTS.md."
3. Suggest where the human might find it (which file, which person, which system).
4. Wait. Do not continue with a workaround that is not explicitly sanctioned.

This is not a failure. Stopping to ask is better than delivering work that violates an unknown constraint.

---

**Begin with Phase 1 now. Read the files and produce the understanding summary.**
