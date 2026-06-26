# Prompt: Session start (clock in)

> **How to use:** Paste this at the start of every agent session in a harnessed project. Optional: wire it as a startup hook so it runs automatically.

---

You are starting a new session on a harnessed project. Before doing any new work, complete the clock-in routine.

## Step 1 — Read state files

In this order:

1. **Root `AGENTS.md`** — load global rules and the area routing table. Note which area-specific AGENTS.md files exist (e.g. `backend/AGENTS.md`, `frontend/AGENTS.md`, `infra/AGENTS.md`).
2. `PROGRESS.md` — current state, active feature, immediate next steps.
3. `DECISIONS.md` — active design constraints. For "Deferred" entries: check if the unblock condition is now met. If yes, flag it to the user before starting work — do not silently ignore a deferred decision that is now actionable.
4. `features.md` — current feature states. Confirm WIP=1: at most one feature is `active`. Note the `Area` tag of the active (or next) feature.
5. **Area-specific `AGENTS.md`** — if the active or next feature has an area tag (e.g. `[BE]`), read that area's AGENTS.md now (e.g. `backend/AGENTS.md`). If it is `[BOTH]`, read all relevant area files. Do not load areas unrelated to today's work.
6. `QUALITY.md` — if any module touching today's work is rated C or D, factor that in.

If `AGENTS.md` does not exist, **stop**. The repo is not properly harnessed yet. Ask the user whether to bootstrap (see `prompts/02-generate-interactive.md`).

## Step 2 — Confirm a clean baseline

Run the appropriate check command:

- **Single-area repo:** `make check`
- **Monorepo, working in one area:** `make check-be` or `make check-fe` (area-specific). Also run `make check` if the change might affect other areas.
- **Monorepo, cross-area feature `[BOTH]`:** `make check` (full, all areas).

All three layers (lint, typecheck, test) must pass for the relevant area(s).

- If **lint/typecheck** fails: the previous session ended unclean. Fix it before starting new work.
- If **tests** fail: investigate — pre-existing (should be in `PROGRESS.md` → "Known Issues") or new regression.
- If the check command does not exist: the Makefile is broken. Fix it before anything else.

**Do not start a new feature on top of a red baseline.**

## Step 3 — Announce intent

State plainly:

- Which feature ID you are picking up (or starting fresh on)
- What `passing` will look like — restate the verification command
- Estimated approach in 2-3 sentences

If the user has not given a specific task, propose the next `not_started` feature from `features.md` and wait for confirmation.

## Step 4 — Mark active

In `features.md`, transition the chosen feature from `not_started` (or `blocked`) to `active`. Confirm no other feature is currently `active` — if there is, that is a WIP violation; ask the user how to resolve it.

In `PROGRESS.md`, update:
- "Active feature" field
- Append a new session entry to "Session History" with today's date

## Step 5 — Work

Proceed with implementation. Remember:

- **WIP=1.** No drive-by refactors. If you spot unrelated cleanup, add it to `DECISIONS.md` → "Deferred", do not act on it.
- **Verify before declaring done.** Three layers (static, behavioral, end-to-end). The feature stays `active` until verification actually passes.
- **No "looks fine" reasoning.** The verification command's exit code is the source of truth.

## Failure modes to watch for

- **Premature convergence (lecture 09).** If you notice yourself thinking "I should just finish this and move on" without verification, stop. That is context anxiety. Run the verification.
- **Phantom progress.** If the diff is large but no verification has run, you do not actually know if anything works. Run something — even a partial smoke test — early.
- **Silent assumption drift.** If your implementation conflicts with `DECISIONS.md`, surface the conflict. Do not pretend it does not exist.

Begin Step 1 now.
