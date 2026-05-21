# Makefile — standardized agent-facing commands.
#
# Why a Makefile? Because the agent should not have to guess project-specific
# invocations. `make setup`, `make test`, `make check` work the same way
# in every project that uses this harness. One mental model, many projects.
#
# Fill in the TODOs for your specific stack. Keep target names stable —
# AGENTS.md, the verification scripts, and the session-start prompt all
# reference these names.

.PHONY: setup dev test lint typecheck e2e check clean session-start session-exit help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

setup: ## Install dependencies + prepare local environment
	@echo "TODO: install dependencies (e.g. uv sync / pnpm install / poetry install)"
	@echo "TODO: copy .env.example to .env if absent"
	@echo "TODO: run database migrations if applicable"

dev: ## Start local dev server (foreground)
	@echo "TODO: e.g. uvicorn app.main:app --reload"

test: ## Run unit + integration tests
	@echo "TODO: e.g. pytest -x --cov=app"

lint: ## Static checks (formatting, lint rules)
	@echo "TODO: e.g. ruff check . && ruff format --check ."

typecheck: ## Type checking
	@echo "TODO: e.g. mypy --strict src/"

e2e: ## End-to-end / smoke tests (cross-component)
	@echo "TODO: e.g. pytest tests/e2e/ or playwright test"

check: lint typecheck test ## Full verification — all three layers
	@echo "All checks passed."

clean: ## Remove build artifacts and caches
	@echo "TODO: e.g. rm -rf .pytest_cache __pycache__ dist build"

session-start: ## Clock-in routine — show repo state, confirm clean baseline
	@echo "=== Session start ==="
	@echo "Latest commit:"
	@git log -1 --oneline 2>/dev/null || echo "  (not a git repo)"
	@echo "Working tree:"
	@git status --short 2>/dev/null || true
	@echo ""
	@echo "Running full check to confirm baseline..."
	@$(MAKE) check

session-exit: ## Clock-out check — five clean-state dimensions
	@bash scripts/session-exit-check.sh
