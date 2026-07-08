# Prompt: Refresh the harness (surgical re-sync with the code)

> **How to use:** Run this when the code may have moved without the harness moving with it — after merging work done outside harnessed sessions (a contractor branch, a teammate's changes, hotfixes), after a stretch of "quick edits" nobody documented, or periodically as hygiene. Optionally tell the agent the baseline: "changes since commit `<hash>`" or "since `<date>`". If you don't, it uses the latest commit recorded in `PROGRESS.md`.
>
> This is **not** prompt 01. Prompt 01 generates the harness from scratch; this prompt makes the **minimum set of edits** to bring an existing harness back in line with reality. A perfectly healthy outcome is "nothing to update."

---

You are re-synchronizing this repo's harness files (AGENTS.md files, `docs/`, `features.md`, `PROGRESS.md`, `QUALITY.md`) with the current state of the code. The code is the source of truth; the harness describes it. Your job is to find where the description has drifted and fix **only that**.

## Operating principles

1. **Surgical, not fresh.** Preserve existing structure and wording wherever it is still accurate. Prefer replacing one stale sentence over rewriting a section. Never regenerate a file that only needs a line changed.
2. **A no-op is a valid outcome.** If nothing drifted, report that and change nothing. Do not invent updates to justify the run.
3. **Soft budget.** If only a handful of source files changed since the baseline, expect to touch at most 1-2 harness docs. A refresh that wants to edit everything is either a huge drift (say so explicitly before proceeding) or you are over-editing.
4. **Evidence over docs.** Where a doc and the code disagree, the code is current — but whether the *code* drifted from an intended convention or the *doc* is stale is a human call. Flag it; do not silently pick.

## Step 1 — Establish the baseline and the delta

1. Find the baseline: the commit recorded in `PROGRESS.md` → "Current State" → "Latest commit", unless the user gave you one.
2. Inspect what changed since then (read-only git): `git log --oneline <baseline>..HEAD` and `git diff --stat <baseline>..HEAD`. Note: files added / deleted / renamed / heavily modified, new directories, dependency manifest changes, new or removed make targets, CI changes.
3. If the baseline cannot be determined (no commit recorded, hash unknown), ask the user for one — do not guess or diff against the beginning of history.

## Step 2 — Build the docs impact plan

For each meaningful change in the delta, map it before editing anything:

```
## Docs impact plan (baseline: <hash> → HEAD, N commits)

| Source change | Harness file affected | Edit needed | Why |
|---|---|---|---|
| app/repo/notifications.py added | backend/docs/architecture.md | add module-map line | new file not on the map |
| Redis client swapped to valkey | backend/AGENTS.md + DECISIONS.md | update stack line; flag: undocumented decision | stack drift, no decision entry |
| tests/e2e/ renamed to tests/system/ | docs/testing.md, features.md verification commands | update paths | commands now broken |
| (nothing else) | — | no-op | remaining changes are internal, docs still accurate |
```

Also check these specific drift points, because they break sessions silently:

- **Verification commands in `features.md`** — do they still run? If paths/targets changed, they are broken contracts.
- **Module maps** — files added/moved/deleted since baseline that the map does not reflect.
- **Makefile targets referenced in AGENTS.md** — still exist and still do what the doc says?
- **Undocumented decisions** — the delta contains a technical choice (new dependency, swapped library, new pattern) with no `DECISIONS.md` entry. You cannot write the reasoning (you don't know it) — list it and ask the user for the "why", then record it.
- **Feature state vs reality** — work in the delta that completes a `not_started`/`active` feature, or breaks a `passing` one. Run the relevant verification commands to confirm before proposing a state change.

**Stop. Show the plan. Do not edit until the user approves it** — they may know context you cannot see (e.g. "that change is being reverted next week").

## Step 3 — Apply, verify, close

After approval:

1. Make exactly the edits in the plan — nothing extra. No drive-by rewording of text that was already accurate.
2. Re-run any verification commands you claimed are fixed or broken, and `make check` (or the touched areas' variants) to confirm the harness's commands all still work.
3. Update `PROGRESS.md` "Current State" to the new latest commit, and add a one-line Session History entry: `YYYY-MM-DD — harness refresh — <N> docs updated (or no-op), baseline <hash>`.
4. Report: what was updated and why, what was flagged for the user (undocumented decisions, doc-vs-code conflicts needing a ruling), and what was verified still green.

## Rules

- **No git write operations** (add / commit / push). Reading git history/diffs is required; writing is the user's.
- **No code changes.** If the delta broke tests or a verification command fails for a *code* reason, that is a finding for the report (and likely a `features.md` state correction + `PROGRESS.md` Known Issue), not something you fix here.
- **Do not re-litigate decisions.** If the code contradicts an Active decision in `DECISIONS.md`, that is the most important finding of the run — surface it prominently and let the human rule. Do not update the decision to match the code on your own.

Begin with Step 1.
