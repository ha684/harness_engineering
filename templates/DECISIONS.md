# DECISIONS.md

<!--
  Design decision log (lecture 05).
  Never delete a decision — supersede it with a new entry that references the old one.
  But DO compress: once a decision is settled and no longer actively debated,
  tighten it to the essential Decision / Reason / Rejected / Constraint lines.
  Keep the record that the decision exists and its supersession chain — only
  shorten the prose. The most recent 1-2 decisions may stay full-length.

  Each entry must have:
    - Date
    - Decision (one line)
    - Reason
    - Rejected alternatives + why
    - Constraints / consequences for future work

  Why keep the record? Because the next agent session cannot ask "why did we
  choose X over Y." If the reason is not here, the new session may re-decide
  and pick differently.

  Why compress? Because this file is read at the start of every session — a
  settled decision's extended discussion is context spent on something no one
  is deciding anymore.

  When Superseded grows past ~5 entries, move the oldest to
  docs/decisions-archive.md (create it if needed). Agents do not read the
  archive unless investigating history.
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
  Compress superseded entries hard — the replacing decision carries the live
  reasoning, so a superseded entry only needs: what it was + why it was replaced.
  Format:
    ### YYYY-MM-DD (superseded YYYY-MM-DD): old decision title
    - **Decision:** [one line]
    - **Why superseded:** [one line — see the replacing entry for full reasoning]
-->

(none yet)
