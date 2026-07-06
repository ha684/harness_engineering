# features.md

<!--
  Feature list — the harness backbone (lecture 08).
  Every feature has a (behavior, verification, state) triple.

  States: not_started | active | blocked | passing
  Rule: only the harness/verifier may transition state to `passing`,
        and only after running the verification command successfully.

  WIP=1 (lecture 07): exactly one feature is `active` at any time.
  For monorepos: WIP=1 globally (one feature active across all areas).

  Area tags (monorepo only — delete column if single-area):
    [BE]   — backend only
    [FE]   — frontend only
    [BOTH] — spans areas; split into sub-features when possible.
             A [BOTH] feature is only `passing` when ALL area verification commands pass.

  Granularity guideline: each feature should be completable in one session.
  Too broad ("implement the shopping cart") — break it down.
  Too narrow ("add the name field") — bundle related changes.

  SIZE CONTROL — this file is read every session; the table must stay small:
  - The Feature List table holds the CURRENT MILESTONE only (~10-20 rows).
  - Ideas not scheduled yet go to Backlog below as one-liners — no verification
    command, no full row. Promote to the table when the milestone starts.
  - When a milestone closes (all its features passing), move its rows to
    docs/features-archive.md verbatim (IDs, evidence and all). IDs are never
    reused or renumbered — the archive preserves them. Numbering continues
    from where it left off (archive ends at F20 → next feature is F21).
-->

## Feature List (current milestone: TODO — name it)

| ID | Behavior | Verification | State | Area | Evidence |
|---|---|---|---|---|---|
| F01 | TODO: one-line behavior description | TODO: executable command | not_started | — | — |
| F02 | TODO | TODO | not_started | — | — |
| F03 | TODO | TODO | not_started | — | — |

## Backlog (not scheduled — one line each)

<!--
  Ideas and future features. NO verification commands, NO states — those get
  written when the item is promoted into the Feature List for a milestone.
  Keeping them as one-liners means 50 backlog ideas cost 50 lines, not 50 rows
  of half-filled table. Group by theme or phase if it helps.
-->

- TODO: e.g. "Push notifications when recipient offline (Phase 3)"
- TODO: e.g. "Message search across conversations"

## Active

<!-- The single currently-active feature, expanded. -->

**ID:** none

**Behavior:** —

**Verification command:** —

**Notes / sub-steps:**
- —

## Blocked

<!-- Features that cannot proceed due to external dependencies. Each must have an unblock condition. -->

(none)

## Passing (this milestone)

<!--
  Do NOT keep a prose log of passing features here — the Feature List table's
  State + Evidence columns are the single source of truth; a prose copy only
  grows unbounded. Use this section only for a note the table cannot hold
  (rare). Usually stays "(none)".
-->

(none yet)

---

## How to use this file

### Adding a feature

1. Pick a stable ID (`F01`, `F02`, ...) — never reuse, never reorder.
2. Write the behavior as a testable user-visible outcome, not an implementation detail.
   - Good: "POST /api/users returns 201 with the created user's ID"
   - Bad: "create a User model and a /users route"
3. Write a verification command that an agent can actually execute. Examples:
   - `pytest tests/test_users.py::test_create_user`
   - `curl -sf -X POST http://localhost:8000/api/users -d '{...}' | jq -e '.id'`
   - `npm run test -- users.spec.ts`
4. Set initial state to `not_started`.

### Working on a feature

1. Pick the next `not_started` feature (or whichever ID the session is targeting).
2. Set state to `active`. **Confirm no other feature is currently `active`** (WIP=1).
3. Implement.
4. Run the verification command. If it passes, set state to `passing` and record the evidence (verification result summary; the user adds the commit hash after they commit). If it fails, fix and re-run. If it cannot be unblocked, set state to `blocked` with the reason.

### Don't fake state

If verification fails, the feature stays `active` or moves to `blocked`. Never set `passing` based on "the code looks fine" — that defeats the entire harness (lecture 09).

### Closing a milestone

When every feature in the current milestone is `passing` (human confirms — this is a judgment call, not an automatic trigger):

1. Move all the milestone's rows to `docs/features-archive.md` verbatim, under a heading with the milestone name and date range.
2. Promote the next batch from Backlog into the table: write their verification commands and set `not_started`.
3. Rename the table heading to the new milestone.

The archive is append-only history; agents do not read it during sessions. If a regression investigation needs an old feature's verification command, it is there.
