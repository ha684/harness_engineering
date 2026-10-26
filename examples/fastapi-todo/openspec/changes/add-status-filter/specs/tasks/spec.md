## ADDED Requirements

### Requirement: Filter tasks by status
The system SHALL return only the tasks matching the optional `status` query parameter, which accepts `completed` or `pending`.

#### Scenario: Completed only
- **WHEN** a client requests `GET /api/tasks?status=completed` with both completed and pending tasks stored
- **THEN** only the completed tasks are returned

#### Scenario: Pending only
- **WHEN** a client requests `GET /api/tasks?status=pending`
- **THEN** only the pending tasks are returned

#### Scenario: No filter
- **WHEN** a client requests `GET /api/tasks` without `status`
- **THEN** all tasks are returned, as before this change

#### Scenario: Unknown status value
- **WHEN** a client requests `GET /api/tasks?status=archived`
- **THEN** the response is 422 and names the allowed values

#### Scenario: Filter combined with pagination
- **WHEN** a client requests `GET /api/tasks?status=pending&size=5` with 12 pending tasks stored
- **THEN** the response holds the 5 newest pending tasks and `next_page` is 2

## MODIFIED Requirements

### Requirement: List tasks
The system SHALL return tasks newest first, paginated, 20 per page by default and at most 100. Tasks with the same `created_at` SHALL be ordered by `id`, descending, so the order is stable across requests.

#### Scenario: Default page
- **WHEN** a client requests `GET /api/tasks` with 25 tasks stored
- **THEN** the response holds the 20 newest tasks, newest first, and `next_page` is 2

#### Scenario: Page size above the limit
- **WHEN** a client requests `GET /api/tasks?size=500`
- **THEN** the response is 422

#### Scenario: Tasks created at the same instant
- **WHEN** several tasks share the same `created_at` and a client lists them twice
- **THEN** both responses return them in the same order, highest `id` first
