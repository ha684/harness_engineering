# Prompt: Compact the harness (review + compress state files)

> **How to use:** Run this as a dedicated maintenance session when the harness itself has gotten heavy — `PROGRESS.md` reads like a novel, `DECISIONS.md` scrolls forever, `features.md` carries three milestones of history. Typically worth running every few milestones, or whenever session starts feel slow because the state files themselves are the context hog.
>
> Per-session compaction (prompt 04) keeps growth slow; this prompt is the deep clean for what accumulated anyway. No code is touched — only harness files.

---

You are compacting this repo's harness state files. These files are read at the start of **every** session, so every stale line in them is a tax on every future session. Your job: cut them down to what a future session actually needs, without losing any record that matters.

## The one invariant — compress prose, never facts

You may shorten, merge, and relocate. You may **not**:

- Delete a decision or break a supersession chain (archive instead)
- Lose a feature ID, its verification command, or its evidence (archive instead)
- Drop a Known Issue, open question, or deferred item that is still live (flag stale ones for the user instead of silently removing)
- Change the *meaning* of anything while shortening it

Everything removed from a hot file lands in an archive file (`docs/decisions-archive.md`, `docs/features-archive.md`, `docs/changelog.md`) — append-only, never read during normal sessions, still there when an investigation needs history.

## Step 1 — Measure

Read every harness file and report actual size vs target:

| File | Target | What "over" usually means |
|---|---|---|
| `PROGRESS.md` | ~100 lines | session history entries never compressed; Completed bullets carrying test counts and file lists |
| `DECISIONS.md` | active section ~150 lines | settled decisions still at full-discussion length; superseded entries not compressed; >5 superseded entries not archived |
| `features.md` | current milestone only, ~20 rows | closed-milestone rows never archived; backlog items written as full rows; prose duplicating the table |
| `QUALITY.md` | one screen | "kept A" logged every session; Score Details restating what docs/ already explain |
| root + area `AGENTS.md` | root <200, areas <150 lines | sections that outgrew ~30 lines without being extracted; area rules leaked into root; duplication between root and area files |
| `docs/*.md` | each earns its load | thin stub pages; the same concept explained in multiple docs; statements contradicted by current code |

Also check: do the files carry self-maintenance comments (the "compress older entries as you go" reminders)? Missing ones get added in Step 3 so growth slows after this clean.

## Step 2 — Propose the compression plan

Before editing anything, show a plan the user can approve at a glance:

```
## Compression plan

| File | Now | After (est.) | Actions |
|---|---|---|---|
| PROGRESS.md | 240 | ~90 | compress 9 old session entries to one-liners; strip test counts from Completed; move milestone-1 completed list to docs/changelog.md |
| DECISIONS.md | 310 | ~140 | tighten 6 settled decisions to Decision/Reason/Rejected/Constraint; compress 3 superseded to 2-liners; archive 2 oldest superseded |
| features.md | 130 | ~60 | archive milestone-1 rows (F01-F12) to docs/features-archive.md; convert 8 unscheduled rows to Backlog one-liners |
| ...

Flags for your decision (not doing these without you):
- Known Issue "flaky test_x" — last mentioned 5 sessions ago; still real?
- Deferred item "Kafka migration" — trigger condition may have arrived
- backend/AGENTS.md duplicates the layering rules already in docs/architecture.md — keep which as canonical?
```

Rules the plan must follow:

- **Recency keeps detail.** The most recent 1-2 session entries, the most recent 1-2 decisions, and the current milestone stay full-length. Everything older gets one line + a pointer (archive, DECISIONS entry, commit hash, doc).
- **One canonical home per fact.** Where two files state the same thing, pick the owner (reasoning → DECISIONS, mechanism → docs/, state → features.md, "where are we" → PROGRESS) and reduce the other to a pointer.
- **Judgment calls go to the user.** Whether a Known Issue is dead, a deferred item is ripe, or a duplicated rule's canonical home — flag, don't decide.

**Stop. Show the plan and the flags. Do not edit until approved.**

## Step 3 — Apply and verify

After approval:

1. Apply exactly the plan. Archives first (so nothing is ever deleted before its copy exists), then compress the hot files.
2. Add the self-maintenance comments to any file missing them (compress-as-you-go reminders in PROGRESS Session History, DECISIONS header, QUALITY History, features.md size-control note) — so the next accumulation is slower.
3. Sanity checks:
   - Every feature ID that existed before still exists somewhere (table or archive) with its verification command and evidence.
   - Every decision title that existed before still exists (active, superseded, or archive), chains intact.
   - `make check` still passes — proves no stray edit touched anything executable.
4. Report before → after line counts per file, where everything went, and the flags that still await the user's ruling.

## Rules

- **No code changes, no git write operations** (add / commit / push).
- **Do not "improve" content while compressing.** Rewording a decision's reasoning, adding new constraints, or editorializing history is out of scope — this session shrinks, it does not author. If you notice something genuinely wrong (not just long), flag it.
- **When unsure whether something is still live, ask.** A wrongly deleted Known Issue costs a future session a re-discovery; a flag costs the user one yes/no.

Begin with Step 1.
