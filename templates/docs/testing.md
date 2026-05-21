# Testing Standards

<!--
  Load this doc when writing or modifying tests.

  Core principle (lecture 10): unit tests are systematically blind to
  component boundary defects. Every cross-component feature MUST have
  an end-to-end test before it can be marked `passing`.
-->

## Test Pyramid (this project)

| Layer | Speed | Scope | Required for |
|---|---|---|---|
| Unit | <1s each | Single function/class | All code |
| Integration | 1-10s each | Multiple components, real dependencies (DB, cache) | All non-trivial features |
| End-to-end | 10s+ each | Full stack, real HTTP/UI | All cross-component features |

## Tools

- **Unit + integration:** TODO (e.g. pytest)
- **End-to-end:** TODO (e.g. httpx + a running test server, or playwright for UI)
- **Coverage:** TODO (e.g. pytest-cov, target 80%+ for service/ and repo/)

## Naming and Organization

```
tests/
├── unit/           # Mirrors src/ layout
├── integration/    # Real DB, real cache, mocked external APIs
└── e2e/            # Full stack, one test = one user-visible scenario
```

Test names should describe behavior, not implementation:
- Good: `test_create_user_returns_201_with_id`
- Bad: `test_user_service_create_method`

## Verification Command Conventions

Every feature in `features.md` has a verification command. Conventions:

- **Single test:** `pytest tests/unit/test_users.py::test_create_user`
- **Module:** `pytest tests/unit/test_users.py`
- **End-to-end via curl:** `curl -sf -X POST http://localhost:8000/api/users -d '{...}' | jq -e '.id'`
- **End-to-end via test runner:** `pytest tests/e2e/test_user_flow.py`

The command must:
1. Exit with code 0 on pass, non-zero on fail
2. Be runnable from the repo root
3. Not depend on test order (no shared state between tests)

## Agent-Friendly Error Messages

When writing custom assertions or test helpers, follow lecture 10's guidance:
**error messages should tell the agent how to fix the problem, not just what failed.**

```python
# Bad
assert response.status_code == 201

# Good
assert response.status_code == 201, (
    f"Expected 201 Created, got {response.status_code}. "
    f"Response body: {response.text}. "
    f"Check that the request body matches the UserCreate schema in src/api/users.py."
)
```

## Forbidden Patterns

- **MUST NOT** use `time.sleep()` to wait for async work — use explicit polling or test fixtures.
- **MUST NOT** rely on test execution order.
- **MUST NOT** test private methods directly — test the public interface.
- **MUST NOT** mock the database in integration tests (lecture-driven: real DB or it doesn't count).

## When a Test Is Flaky

A flaky test is worse than no test — it teaches the agent to ignore failures. Either:
1. Fix the root cause (race condition, leaked state, time dependency), or
2. Skip the test with a tracked TODO + entry in `DECISIONS.md` under "Deferred"

Never just retry until it passes.
