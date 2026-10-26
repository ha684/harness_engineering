---
description: End of session — leave the work so the next session can pick it up cold
---

Wrap up this session:

1. If an OpenSpec change is in progress, tick the finished boxes in its `tasks.md` and rewrite the `## Handoff` section at the bottom: where things stand, the next concrete step, anything surprising you learned, and open questions for me. A few lines — it's the first thing the next session reads.
2. If the change is complete, run `make check`. If it isn't, run the tests for what you touched. Report results exactly as they came out.
3. Remove anything you added only for debugging.
4. If you added, moved or removed files, update the module map in `docs/architecture.md`. If we settled something project-wide, update `DECISIONS.md`.
5. If something failed this session, a specific change fixed it, and a future session would plausibly hit the same thing, record it as a lesson — format in `lessons/INDEX.md`. Evidence is required; if it's only a hunch, skip it.
6. Don't commit. List the files you changed and suggest a commit message.

$ARGUMENTS
