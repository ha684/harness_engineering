"""Tests for the add-status-filter change — one test per spec scenario.

Spec: openspec/changes/add-status-filter/specs/tasks/spec.md
Illustrative: the app code isn't part of this example. `client` is an httpx
AsyncClient against the app; `make_task` inserts straight into the real test
database (see tests/conftest.py in a real project).
"""

from datetime import datetime, timezone


async def test_completed_only(client, make_task):
    """Requirement: Filter tasks by status — Scenario: Completed only."""
    done = await make_task(title="done", completed=True)
    await make_task(title="todo", completed=False)

    response = await client.get("/api/tasks", params={"status": "completed"})

    assert response.status_code == 200, response.text
    assert [t["id"] for t in response.json()["items"]] == [done.id], (
        f"Expected only the completed task, got {response.json()['items']}. "
        "The filter belongs in TaskRepo.list (app/repo/tasks.py)."
    )


async def test_pending_only(client, make_task):
    """Requirement: Filter tasks by status — Scenario: Pending only."""
    await make_task(title="done", completed=True)
    todo = await make_task(title="todo", completed=False)

    response = await client.get("/api/tasks", params={"status": "pending"})

    assert [t["id"] for t in response.json()["items"]] == [todo.id], response.text


async def test_no_filter_returns_everything(client, make_task):
    """Requirement: Filter tasks by status — Scenario: No filter."""
    await make_task(completed=True)
    await make_task(completed=False)

    response = await client.get("/api/tasks")

    assert len(response.json()["items"]) == 2, response.text


async def test_unknown_status_value_is_rejected(client):
    """Requirement: Filter tasks by status — Scenario: Unknown status value."""
    response = await client.get("/api/tasks", params={"status": "archived"})

    assert response.status_code == 422, (
        f"Expected 422 for an unknown status, got {response.status_code}: {response.text}. "
        "Validation belongs in the query model in app/api/tasks.py."
    )
    assert "completed" in response.text and "pending" in response.text


async def test_filter_combined_with_pagination(client, make_task):
    """Requirement: Filter tasks by status — Scenario: Filter combined with pagination."""
    for i in range(12):
        await make_task(title=f"todo {i}", completed=False)
    await make_task(title="done", completed=True)

    response = await client.get("/api/tasks", params={"status": "pending", "size": 5})

    body = response.json()
    assert [t["title"] for t in body["items"]] == [f"todo {i}" for i in range(11, 6, -1)], body
    assert body["next_page"] == 2


async def test_tasks_created_at_the_same_instant_keep_a_stable_order(client, make_task):
    """Requirement: List tasks — Scenario: Tasks created at the same instant.

    The hard case: without an id tiebreak PostgreSQL may return rows sharing a
    created_at in any order, so this fails intermittently rather than always.
    """
    instant = datetime(2026, 5, 18, 9, 0, tzinfo=timezone.utc)
    ids = [(await make_task(created_at=instant)).id for _ in range(5)]

    first = [t["id"] for t in (await client.get("/api/tasks")).json()["items"]]
    second = [t["id"] for t in (await client.get("/api/tasks")).json()["items"]]

    assert first == second == sorted(ids, reverse=True), (
        f"Order changed between requests or isn't id-descending: {first} vs {second}. "
        "Add `id DESC` as the tiebreak in TaskRepo.list."
    )
