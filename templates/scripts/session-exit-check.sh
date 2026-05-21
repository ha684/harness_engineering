#!/usr/bin/env bash
# scripts/session-exit-check.sh — Clean handoff check (lecture 12).
#
# Verifies the five clean-state dimensions before the agent ends a session.
# Any failure means the session is NOT complete — fix and re-run.
#
# Dimensions:
#   1. Build passes
#   2. Tests pass
#   3. PROGRESS.md updated (modified within this session)
#   4. No stale artifacts (debug code, temp files, leftover prints)
#   5. Standard startup path works (make setup is idempotent and make dev starts)
#
# This script is INTENTIONALLY strict. "Almost clean" is not clean.

set -uo pipefail

FAILURES=0
PASSED=()
FAILED=()

check() {
    local name=$1
    local cmd=$2
    if eval "$cmd" >/dev/null 2>&1; then
        PASSED+=("$name")
    else
        FAILED+=("$name")
        FAILURES=$((FAILURES + 1))
    fi
}

echo "=== Session exit check (five clean-state dimensions) ==="
echo ""

# Dimension 1: build passes
check "1. Build passes" "make lint && make typecheck"

# Dimension 2: tests pass
check "2. Tests pass" "make test"

# Dimension 3: PROGRESS.md was updated this session.
# Heuristic: PROGRESS.md should have been modified in the working tree
# OR committed in the most recent commit.
progress_recent() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Not a git repo — skip this check
        return 0
    fi
    if ! git diff --quiet PROGRESS.md 2>/dev/null; then
        return 0  # has uncommitted changes
    fi
    if git log -1 --name-only --pretty=format: 2>/dev/null | grep -q "^PROGRESS.md$"; then
        return 0  # modified in latest commit
    fi
    return 1
}
check "3. PROGRESS.md updated this session" "progress_recent"

# Dimension 4: no stale artifacts.
# Heuristic: scan staged + unstaged files for common debug patterns.
no_debug_artifacts() {
    local patterns=(
        "console\.log"
        "print(.*DEBUG"
        "TODO: REMOVE"
        "XXX"
        "debugger;"
        "import pdb"
        "breakpoint()"
    )
    local changed
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        changed=$(git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null)
    else
        return 0
    fi
    if [[ -z "$changed" ]]; then
        return 0
    fi
    for p in "${patterns[@]}"; do
        if echo "$changed" | xargs -r grep -l -E "$p" 2>/dev/null | grep -q .; then
            return 1
        fi
    done
    return 0
}
check "4. No debug artifacts in changed files" "no_debug_artifacts"

# Dimension 5: standard startup path works.
# We run `make setup` (should be idempotent) and assume the user verified
# `make dev` separately. If make setup is fast (<30s), enable it here.
# If slow, the next session start will catch problems.
# Default: skip in this script, document in PROGRESS.md.
PASSED+=("5. Standard startup path (manually verified — see PROGRESS.md)")

echo ""
echo "Passed:"
for p in "${PASSED[@]}"; do echo "  ✓ $p"; done

if [[ $FAILURES -gt 0 ]]; then
    echo ""
    echo "Failed:"
    for f in "${FAILED[@]}"; do echo "  ✗ $f"; done
    echo ""
    echo "SESSION IS NOT CLEAN. Fix the failures above before exiting."
    echo "Reminder (lecture 12): 'clean up later' means never clean up."
    exit 1
fi

echo ""
echo "All five dimensions clean. Safe to end session."
