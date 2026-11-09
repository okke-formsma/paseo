#!/usr/bin/env bash
# Mirror upstream main into the fork's main and rebase our patch branch on top.
# Exits non-zero and leaves the rebase in progress when a patch conflicts.
set -euo pipefail
cd "$(dirname "$0")/.."

BRANCH=okke

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "sync: working tree has uncommitted changes; commit or discard them first" >&2
  exit 2
fi

git fetch --prune upstream --tags
git fetch --prune origin

# Fork main is a pure mirror of upstream main (fast-forward only).
git push origin upstream/main:refs/heads/main

git checkout "$BRANCH"
before=$(git rev-parse HEAD)
git rebase upstream/main
after=$(git rev-parse HEAD)
git push --force-with-lease origin "$BRANCH"

if [[ "$before" == "$after" ]]; then
  echo "sync: $BRANCH already up to date with upstream/main"
else
  echo "sync: rebased $BRANCH onto upstream/main ($(git rev-parse --short upstream/main))"
fi
echo "sync: patches on top of upstream:"
git log --oneline upstream/main..HEAD
