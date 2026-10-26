# Tasks Specification

## Purpose

Creating, reading and listing a user's todo tasks over HTTP.

## Requirements

### Requirement: Create a task
The system SHALL create a task from a title and return it with its new ID.

#### Scenario: Valid task
- **WHEN** a client sends `POST /api/tasks` with `{"title": "Buy milk"}`
- **THEN** the response is 201 with the task's `id`, `title`, `completed: false` and `created_at`

#### Scenario: Missing or blank title
- **WHEN** a client sends `POST /api/tasks` with no title, or a title of only whitespace
- **THEN** the response is 422 and no task is stored

### Requirement: Get a task
The system SHALL return a single task by ID.

#### Scenario: Existing task
- **WHEN** a client requests `GET /api/tasks/{id}` for a stored task
- **THEN** the response is 200 with that task

#### Scenario: Unknown ID
- **WHEN** a client requests `GET /api/tasks/{id}` for an ID that doesn't exist
- **THEN** the response is 404

### Requirement: List tasks
The system SHALL return tasks newest first, paginated, 20 per page by default and at most 100.

#### Scenario: Default page
- **WHEN** a client requests `GET /api/tasks` with 25 tasks stored
- **THEN** the response holds the 20 newest tasks, newest first, and `next_page` is 2

#### Scenario: Page size above the limit
- **WHEN** a client requests `GET /api/tasks?size=500`
- **THEN** the response is 422
