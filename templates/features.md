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
-->

## Feature List

| ID | Behavior | Verification | State | Area | Evidence |
|---|---|---|---|---|---|
| F01 | TODO: one-line behavior description | TODO: executable command | not_started | — | — |
| F02 | TODO | TODO | not_started | — | — |
| F03 | TODO | TODO | not_started | — | — |

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
4. Run the verification command. If it passes, set state to `passing` and record the commit hash in Evidence. If it fails, fix and re-run. If it cannot be unblocked, set state to `blocked` with the reason.

### Don't fake state

If verification fails, the feature stays `active` or moves to `blocked`. Never set `passing` based on "the code looks fine" — that defeats the entire harness (lecture 09).
