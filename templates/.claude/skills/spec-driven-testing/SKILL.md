---
name: spec-driven-testing
description: How to write, choose, and run tests in this project. Use when implementing an OpenSpec change, writing or editing tests, deciding what to test, or deciding when to run the test suite. Tests here are executable specs — a few high-value tests derived from spec scenarios, run at checkpoints rather than after every edit.
---

# Spec-driven testing

A test in this project exists to prove that a spec scenario holds. That gives three rules for everything below: tests come **from the spec**, they check **behavior from the outside**, and there are **few of them** — each one should be capable of catching a real bug.

## What to test

Start from the scenarios in the change's spec deltas (`openspec/changes/<name>/specs/`), or in `openspec/specs/` for existing behavior.

- **One focused test per scenario that a bug could plausibly break.** Name it after the scenario, and reference the requirement in a docstring or comment, so a reader can go from test to spec and back.
- **Spend effort where bugs live:** failure paths, edge and boundary values, ordering and concurrency, state that persists across requests, the seam between two components. A single good test of "two tasks created in the same millisecond keep a stable order" is worth more than ten tests of the happy path.
- **Skip what can't break meaningfully:** trivial getters and mappings, framework behavior, configuration constants, private helpers.
- If a scenario can't be checked from outside, the scenario is probably underspecified — tell the user rather than testing internals to compensate.
- **Bug fixes outside an OpenSpec change** get one test that reproduces the bug through the same boundary: it must fail before the fix and pass after. Name it after the behavior that broke, not the ticket number. If no spec scenario covered that behavior, mention the gap in your summary.

## How to write them

- **Go through the public boundary** — HTTP endpoint, CLI, UI flow, or the module's public API. Assert on what a user or caller can observe: the response, the persisted state, the emitted event.
- **Use real dependencies when they're cheap** (a database in a container, the real filesystem). Fake only what is slow, external, or nondeterministic: third-party APIs, the clock, randomness.
- **Don't assert on implementation:** which internal function was called, mock call counts, private attributes, full-object snapshots. Those tests break on every refactor and catch nothing.
- **Write failure messages that say what to fix**, not just what differed — include the actual response or state, and where to look.
- Match the size and style of the neighboring test files.

## The order: test first

For each scenario: write the test, run it, and see it fail *for the expected reason* (not an import error or a typo). Then implement until it passes. The failing test is the contract — it keeps "looks done" honest.

Scratch checks you write to explore or debug are fine. Delete them afterwards; don't promote them into permanent tests.

## When to run what

Running the whole suite after every edit is slow and tells you nothing new. Instead:

- **While iterating:** run only the test(s) for the scenario you're working on — `make test T=<path or selector>`.
- **Static checks** (`make lint`): whenever convenient; they're fast.
- **Once, when the change is complete:** `make check` — the full suite. Also before an OpenSpec archive.

If the full run shows a failure outside what you touched, investigate whether your change caused it before assuming it's pre-existing.

## When a test fails

Fix the code. Change a test only when the spec it encodes changed — and then change the spec delta in the same change. Never weaken an assertion, add a skip, or delete a test to get green; if you believe a test is wrong, say so and explain why.

A flaky test is worse than none — it teaches everyone to ignore red. Find the cause (shared state, timing, ordering) or remove it and tell the user.

If a test keeps breaking on refactors that don't change behavior, it's testing implementation. Rewrite it against the behavior or propose deleting it.

## Example

Spec delta:

```markdown
### Requirement: Filter tasks by status
The system SHALL return only tasks matching the `status` query parameter.

#### Scenario: Unknown status value
- **WHEN** a client requests `GET /api/tasks?status=archived`
- **THEN** the response is 422 and names the allowed values
```

Test:

```python
async def test_unknown_status_value_is_rejected(client):
    """Requirement: Filter tasks by status — Scenario: Unknown status value."""
    response = await client.get("/api/tasks", params={"status": "archived"})

    assert response.status_code == 422, (
        f"Expected 422 for an unknown status, got {response.status_code}: {response.text}. "
        "Validation belongs in the query model in app/api/tasks.py."
    )
    assert "completed" in response.text and "pending" in response.text
```

It goes through HTTP, checks only what a client sees, and would fail if validation were removed or moved somewhere that let the bad value reach the database.
