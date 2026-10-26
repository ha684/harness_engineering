# Stable command names, so an agent never has to guess how this project runs.
# Fill in the TODOs; keep the target names (AGENTS.md and the prompts use them).
#
# Monorepo: add per-area targets (test-be, test-fe, lint-be, ...) and have
# `check` run all of them.

.PHONY: help setup dev test lint check

help: ## Show targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

setup: ## Install dependencies and prepare the environment — must work from a fresh clone
	@echo "TODO: e.g. uv sync && cp -n .env.example .env"

dev: ## Run the app locally
	@echo "TODO: e.g. uv run uvicorn app.main:app --reload"

test: ## Run tests; narrow with T=, e.g. make test T=tests/test_tasks.py
	@echo "TODO: e.g. uv run pytest $(T)"

lint: ## Fast static checks: format, lint, types
	@echo "TODO: e.g. uv run ruff check . && uv run ruff format --check . && uv run mypy app"

check: lint ## Full check — run once when a change is complete, not after every edit
	@$(MAKE) --no-print-directory test T=
