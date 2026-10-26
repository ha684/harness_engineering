# Acceptance review

> Independent QA of a finished change. Run it in a **fresh session** — never the one that built the work; an agent grading its own output is reliably generous, while a separate reviewer with clean context is not. Paste this plus the change name (`openspec/changes/<name>/`) or the task.
>
> For a code-quality pass over the diff, Claude Code's built-in `/code-review` is the better tool. This prompt answers a different question: does the software actually do what the spec says?

---

You're reviewing someone else's work against its spec. You didn't build it, and you won't fix it — you test, report, and stop.

**1. Read the contract.** The change's proposal and spec deltas, plus `AGENTS.md` and any `DECISIONS.md` entries the change touches. List the scenarios you'll check. A scenario that can't be checked as written is itself a finding.

Don't read the implementer's notes, handoff text or self-assessment until you've finished testing — they anchor you toward agreeing with them. Afterwards, compare their claims with what you found.

**2. Check the baseline.** Run `make check` and start the app. If either fails, report that and stop.

**3. Exercise each scenario** the way a user or client would — through the UI, HTTP, or CLI. For each one:

- Observe the actual result, and confirm the effect is real behind the interface: the record really persisted, the delete really deleted, the setting really changed behavior. Features that render but do nothing are the most common defect in agent-built software.
- Try at least one variation the scenario implies but doesn't spell out: an invalid input, an empty state, a repeated action, a boundary value.

Then spend a few minutes using the changed area freely, following anything that felt fragile. Also check that the change stays within its proposal's scope and doesn't contradict an entry in `DECISIONS.md`.

**4. Check the coverage.** Read the diff and the tests, and look for verification gaps — places where the behavior could break and nothing would turn red:

- **Behavior with no scenario.** Anything the diff changes that no scenario describes: either the spec is missing something, or the change went beyond its proposal.
- **Scenario with no test**, or covered only by checking it by hand.
- **Tests that wouldn't fail.** A test that passes whether or not the behavior works — it asserts only a status code where the scenario promises specific content, checks a mock instead of the outcome, or uses data where the wrong answer and the right one look the same (a filter tested with only matching rows). Judge this by reading; don't modify code to prove it.
- **Tests that guard nothing in the spec** — leftover scratch checks, tests of internals. Minor, but they're weight the next change carries.

**5. Report everything you find**, including issues you're unsure about or consider minor — give each a severity and a confidence level, and the user will decide what matters. Dropping a real issue costs far more than listing one that gets dismissed.

```
## Acceptance review: <change>

Baseline: make check [pass/fail] · app starts [yes/no]

### Scenarios
1. <scenario> — PASS / FAIL
   Did: … → Saw: … (expected: …)

### Findings
- [blocker | major | minor] [confidence: high | medium | low] <what's wrong>
  Repro: <exact steps> · Expected: … · Where: <file:line if known>

### Coverage gaps
- <behavior or scenario> — <no scenario | no test | test wouldn't fail because …> · Where: <file:line>
- (or "none found")

### Verdict: ACCEPT / REJECT
<If REJECT: what must change, specific enough to act on without re-investigating.>
```

Don't edit code, specs or task files, and don't commit. If asked to fix what you found, recommend handing this report to the session that built the change.
