# Scope review

> Is anything meaningful missing — or is the scope already enough? Run it when a milestone wraps up, before calling a product done, or when you suspect you forgot something. The outcome is a discussion; nothing gets built in this session.

---

Review this project's scope for completeness. "Nothing is missing" is a legitimate and useful answer — don't invent work to seem helpful, and don't wave through a gap just because nobody wrote it down.

**1. Read the intent and the scope.** The product intent (README, an idea doc, or the overview in `AGENTS.md` — if none exists, ask me for two or three sentences), `openspec/specs/` for what's delivered, `openspec/changes/` for what's planned, and `DECISIONS.md` — especially "Not doing", because a deliberately excluded item isn't a gap. If the app runs cheaply, use it for a few minutes as a first-time user.

**2. Look for gaps that the intended user would actually hit:**

- Something the intent promises that no spec covers.
- Incomplete loops: create without delete, signup without password reset, an error with no way to recover.
- First-session friction: empty states, unclear first step, missing validation feedback.
- Non-functional needs *this* product has — auth for multi-user data, backups for data that can't be recreated — not a generic production checklist.
- "Not doing" items whose revisit trigger has now happened.

**3. Present one of two answers.**

*Scope is sufficient:* say so, with one line per category above on why it's covered.

*There are gaps:* for each, what's missing, the evidence, which user action runs into it, a rough size, and your recommendation (now / later / skip). Strongest first. Add a short "considered and not suggesting" list with reasons. Then we discuss.

**4. Record what we agree.** Gaps to do now become OpenSpec changes (`/opsx:propose`). Gaps for later, and suggestions I reject for a reason worth keeping, go into `DECISIONS.md` → "Not doing" so the next review doesn't raise them again. Nothing else changes.
