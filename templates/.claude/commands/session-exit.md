---
description: Clock out — verify five clean-state dimensions, compact state files, hand off
---

End this session with a clean handoff. A session is not over until all five dimensions PASS — if any is FAIL, fix it now, do not exit:

1. **Build passes** — lint + typecheck exit 0.
2. **Tests pass** — full test suite exits 0; re-run the specific verification command of any feature marked `passing` this session.
3. **PROGRESS.md updated** — current state, completed, in-progress, known issues, concrete next step, session history entry. Then **compact**: compress session-history entries older than the most recent 1-2 to one line each; tighten settled decisions in `DECISIONS.md`; update the module map in `docs/architecture.md` if files were added/moved/renamed/deleted.
4. **No stale artifacts** — no debug prints, commented-out blocks, temp files, fresh TODO/FIXME without a Deferred entry.
5. **Startup path works** — `make setup` reflects any new deps/env vars/migrations; `make dev` still starts.

Then:
- Capture any technical decisions made this session that are not yet in `DECISIONS.md`.
- Re-score `QUALITY.md` if a module's quality changed.
- **Do not run git write operations (add / commit / push)** — list every changed file (source + harness state) and suggest a commit message; the user handles version control.
- Summarize: features moved to `passing`, features still active/blocked and why, changed files, next session's first concrete action, anything the user must decide.

$ARGUMENTS
