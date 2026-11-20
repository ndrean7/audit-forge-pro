#!/bin/sh
# pro-init.sh — scaffold a local Audit Forge Pro workspace.
# Usage: sh scripts/pro-init.sh /path/to/repo-copy <commit>
# Creates ./pro-workspace-<name>/ holding a copy of the repo, a test/
# directory for PoCs, and a scope record. The original repo is never
# touched. All PoCs run locally with `forge test` — no chain, no keys.
set -e

if [ "$#" -ne 2 ]; then
    echo "usage: sh scripts/pro-init.sh /path/to/repo-copy <commit>"
    exit 1
fi

SRC="$1"
COMMIT="$2"
NAME=$(basename "$SRC")
DEST="./pro-workspace-$NAME"

if [ -e "$DEST" ]; then
    echo "workspace already exists: $DEST"
    exit 1
fi

mkdir -p "$DEST"
cp -r "$SRC"/. "$DEST"/
mkdir -p "$DEST/test"

{
    echo "Audit Forge Pro — scope record"
    echo "repo: $SRC"
    echo "commit: $COMMIT"
    echo "workspace: $DEST"
    echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""
    echo "in scope: (fill in — files and functions under review)"
    echo "out of scope: (fill in)"
    echo "economic surface: (fill in — which functions move value, in which token, to whom)"
    echo "accounting invariant: (fill in — one sentence per value flow)"
    echo "trusted assumptions: (fill in — multisig, oracle, backend, relayer)"
} > "$DEST/SCOPE.md"

echo "workspace ready: $DEST"
echo "scope record: $DEST/SCOPE.md"
echo "write PoCs in: $DEST/test  (run with: forge test)"
