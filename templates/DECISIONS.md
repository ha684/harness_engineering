# DECISIONS.md

<!--
  Design decision log (lecture 05).
  Append-only. Never delete entries — supersede them with new entries that reference the old one.

  Each entry must have:
    - Date
    - Decision (one line)
    - Reason
    - Rejected alternatives + why
    - Constraints / consequences for future work

  Why? Because the next agent session cannot ask "why did we choose X over Y."
  If the reason is not here, the new session may re-decide and pick differently.
-->

## Active Decisions

### YYYY-MM-DD: TODO — example decision title

- **Decision:** TODO (one sentence)
- **Reason:** TODO (the constraint or trade-off that drove this)
- **Rejected alternative:** TODO (what we did not pick, and why)
- **Constraint going forward:** TODO (what this implies for future changes)

<!-- Add new entries here as decisions are made. Most recent at the top. -->

## Deferred Items

<!--
  Things the agent noticed but decided NOT to do (WIP=1, lecture 07).
  Each item should be promotable to a feature in features.md when the time comes.
-->

- TODO: e.g. "Refactor error middleware — currently duplicated across 3 routers. Not blocking, defer to dedicated session."

## Superseded Decisions

<!--
  When a new decision replaces an old one, move the old one here with a reference.
  Format:
    ### YYYY-MM-DD (superseded YYYY-MM-DD): old decision title
    [original entry]
    **Superseded by:** [new decision title]
-->

(none yet)
