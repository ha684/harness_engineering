---
description: Clock in — read state files, confirm clean baseline, pick a feature
---

Start a session on this harnessed project. Follow the **Session Lifecycle → clock in** steps in the root `AGENTS.md` exactly, in order. Key rules:

1. Read root `AGENTS.md`, `PROGRESS.md`, `DECISIONS.md` (Active + Deferred only), `features.md`. Confirm WIP=1.
2. Load the area-specific `AGENTS.md` for the active/next feature's area tag (monorepo only). Do not load unrelated areas.
3. Use the module map in the area's `docs/architecture.md` to locate the feature's touch zone — read only those files, but read every file you are about to modify.
4. Run the area's check command. **Do not start a new feature on a red baseline** — fix lint/typecheck failures first; investigate test failures against "Known Issues".
5. Announce intent: feature ID, what `passing` looks like (verification command), approach in 2-3 sentences. If no task was given, propose the next `not_started` feature and wait for confirmation.
6. Mark the feature `active` in `features.md`; update `PROGRESS.md` "Active feature" + add a Session History entry.

While working: WIP=1, no drive-by refactors (note them in `DECISIONS.md` → Deferred), verification exit code is the only source of truth — never "looks fine".

$ARGUMENTS
