# Prompt: Scope review (what's missing — if anything)

> **How to use:** Run this when you want a second opinion on completeness: after a milestone closes, before calling a product "done," or whenever you have the nagging feeling you forgot something. Works in a fresh session or an existing one.
>
> The output is a **discussion**, not a work order. The agent proposes gaps (or explicitly declares the scope satisfied), you discuss, and only what you approve enters `features.md`. Nothing gets implemented in this session.

---

You are reviewing this project's scope for completeness. The question you are answering: **given what this product is trying to be, is anything meaningful missing — or is the current scope genuinely sufficient?**

Both answers are legitimate outcomes. Hold these two failure modes in tension:

- **Do not invent work to seem useful.** A reviewer who always finds "gaps" is as worthless as one who never does. Suggesting nice-to-haves the product does not need, enterprise patterns a hobby project will never want, or speculative features "users might like" is noise. If the scope is sufficient, say so plainly and stop — "no additions needed" is a complete, valuable answer.
- **Do not rubber-stamp.** If the product claims to be X and is missing something every X needs, that is a real gap even if no one wrote it down. The absence of a feature from `features.md` does not mean it was deliberately excluded — check `DECISIONS.md` before assuming.

## Step 1 — Understand the intent

Read, in this order:

1. The product intent — `idea.md`, a spec, or the Project Overview in root `AGENTS.md`. This defines what "complete" means. If no written intent exists, ask the user to state it in 2-3 sentences before proceeding.
2. `features.md` — current milestone table, Backlog, and `docs/features-archive.md` if it exists. What has been delivered, what is planned, what was already deferred.
3. `DECISIONS.md` — Active and Deferred. **Critical:** many "missing" things were deliberately excluded or postponed with reasons. A gap that was consciously deferred is not a finding — it is already tracked.
4. Skim the module map in `docs/architecture.md` to know what actually exists in code.
5. If the app runs cheaply (`make dev`), spend a few minutes using it as a first-time user — the gaps users hit in the first five minutes rarely appear in feature lists.

## Step 2 — Gap analysis

Compare intent against delivered + planned scope. Check these categories in order — earlier categories matter more:

1. **Broken promises** — the intent says the product does X; nothing in features.md (any state) covers X.
2. **Incomplete loops** — a feature exists but its obvious counterpart is missing: create without delete, write without read, signup without password reset, error states with no recovery path.
3. **First-session friction** — things every real user needs immediately that feature lists forget: empty states, input validation feedback, the obvious "what do I do first" path.
4. **Load-bearing non-functionals** — only those this specific product actually needs (auth for multi-user data, backups for irreplaceable data, rate limits for public endpoints). Do not propose generic "production readiness" for a product that does not need it.
5. **Known-gap hygiene** — items in DECISIONS.md → Deferred whose trigger condition has now arrived, or Backlog items that have silently become urgent.

For every candidate gap, apply this filter before including it: **would the intended user hit this in normal use, and does the product's stated intent imply it should work?** If either answer is no, drop it or demote it to a one-line "noticed, probably not needed" mention.

## Step 3 — Present for discussion

Produce exactly one of these two outputs.

**If the scope is sufficient:**

```
## Scope review: satisfied

I compared [intent source] against delivered + planned scope and found no
meaningful gaps. Specifically checked: [the 5 categories, one line each on
why each is covered].

Minor observations (no action suggested): [0-3 one-liners, or "none"]
```

Do not pad this with speculative suggestions to justify the review. Done is done.

**If there are gaps:**

```
## Scope review: [N] suggestions

### S1 — [short name]   (category: broken promise / incomplete loop / ...)
- Gap: [what is missing, concretely]
- Evidence: [where the intent implies it + what I checked to confirm it is absent]
- Who hits it: [the user action that runs into this]
- Rough size: [one session / a few sessions / a milestone]
- My take: [add to current milestone / add to Backlog / probably skip — and why]

### S2 — ...

Not suggesting: [1-3 things you considered and rejected, one line each with why —
this shows the filter was applied, and often surfaces the discussion the user
actually wants to have]
```

Order suggestions by how confident you are that they are real gaps, strongest first. Then **stop and discuss**. Answer questions, take pushback, revise or withdraw suggestions. The user decides what enters scope — you inform the decision.

## Step 4 — Record the outcome (only after agreement)

For each suggestion the user accepts:
- Scheduled now → add a row to the `features.md` current-milestone table (behavior + verification command + `not_started` + area tag).
- Later → add a one-liner to `features.md` Backlog.

For each suggestion the user rejects with a reason worth remembering, offer to add one line to `DECISIONS.md` → Deferred (or a rejection note) so the next scope review does not re-raise it.

If the outcome was "satisfied," offer to note in `PROGRESS.md` that a scope review passed on this date — useful context for the next session.

## Rules

- **No implementation.** This session changes at most `features.md`, `DECISIONS.md`, and a one-line `PROGRESS.md` note — and only after explicit agreement. No code.
- **No git write operations** (add / commit / push).
- **Respect prior decisions.** If DECISIONS.md already rejected or deferred something, do not re-propose it unless its stated conditions have changed — and if you do, say explicitly which condition changed.

Begin with Step 1.
