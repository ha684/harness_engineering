#!/usr/bin/env bash
# scripts/verify.sh — Three-layer verification (lectures 09, 10).
#
# Runs static → behavioral → end-to-end checks. Stops at the first failing
# layer. The agent MUST NOT proceed to the next layer if the previous one
# failed.
#
# Exit codes:
#   0  — all layers passed
#   1  — static (lint/typecheck) failed
#   2  — behavioral (unit + integration tests) failed
#   3  — end-to-end failed
#
# Error messages follow the "agent-friendly" pattern (lecture 10): each
# failure tells the agent what went wrong AND where to look to fix it.

set -uo pipefail

LAYER_NAME=""
LAYER_HINT=""

fail() {
    local exit_code=$1
    local layer=$2
    local hint=$3
    echo ""
    echo "FAIL: $layer layer failed."
    echo "WHY:  the agent must not advance past this layer."
    echo "FIX:  $hint"
    exit "$exit_code"
}

echo "=== Layer 1: static checks ==="
if ! make lint; then
    fail 1 "static" "Fix lint errors. Run 'make lint' to see them. Common causes: formatting, unused imports, type ignores."
fi
if ! make typecheck; then
    fail 1 "static (typecheck)" "Fix type errors. Run 'make typecheck' to see them. If the error is in code you did not touch, ask before changing it."
fi

echo ""
echo "=== Layer 2: behavioral checks ==="
if ! make test; then
    fail 2 "behavioral" "Fix failing tests. Run 'make test' to see them. If a test failure is in unrelated code, that means your change had a side effect — investigate before changing the test."
fi

echo ""
echo "=== Layer 3: end-to-end checks ==="
# E2E is only required when the change crosses component boundaries.
# If the Makefile's e2e target is a no-op (because the feature is single-component),
# this layer passes trivially.
if ! make e2e; then
    fail 3 "end-to-end" "Fix the end-to-end failure. Unit tests passing is NOT enough for cross-component changes (lecture 10). Check: interface contracts between layers, state propagation, resource lifecycle, environment config."
fi

echo ""
echo "All three layers passed. Safe to mark feature as 'passing' in features.md."
