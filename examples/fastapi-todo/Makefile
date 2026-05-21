# Makefile — fastapi-todo example
#
# This is a real, working set of commands for the example stack
# (Python 3.11 + FastAPI + PostgreSQL + uv).

.PHONY: setup setup-test-db dev test lint typecheck e2e check clean session-start session-exit help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

setup: ## Install dependencies + prepare local environment
	uv sync
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env from .env.example — review before running"; fi
	docker compose up -d postgres
	uv run alembic upgrade head

setup-test-db: ## Start a clean test database
	docker compose up -d postgres-test
	TEST_DATABASE_URL="postgresql+asyncpg://test:test@localhost:5433/test" uv run alembic upgrade head

dev: ## Start local dev server
	uv run uvicorn app.main:app --reload --port 8000

test: setup-test-db ## Run unit + integration tests
	uv run pytest -x --cov=app --cov-report=term-missing

lint: ## Ruff lint + import-linter
	uv run ruff check .
	uv run ruff format --check .
	uv run lint-imports

typecheck: ## mypy --strict
	uv run mypy --strict app/

e2e: setup-test-db ## End-to-end tests (full stack via httpx)
	uv run pytest tests/e2e/ -v

check: lint typecheck test ## Full three-layer verification
	@echo "All checks passed."

clean: ## Remove caches and build artifacts
	rm -rf .pytest_cache .mypy_cache .ruff_cache .coverage htmlcov dist build
	find . -type d -name __pycache__ -exec rm -rf {} +

session-start: ## Clock-in routine
	@echo "=== Session start ==="
	@echo "Latest commit:"
	@git log -1 --oneline
	@echo "Working tree:"
	@git status --short
	@echo ""
	@echo "Running full check to confirm baseline..."
	@$(MAKE) check

session-exit: ## Clock-out check
	@bash scripts/session-exit-check.sh
