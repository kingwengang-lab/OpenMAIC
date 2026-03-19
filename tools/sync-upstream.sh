#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: this command must be run inside a git repository." >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "Error: remote 'upstream' is not configured." >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: remote 'origin' is not configured." >&2
  exit 1
fi

current_branch="$(git rev-parse --abbrev-ref HEAD)"
status_output="$(git status --porcelain)"

if [[ -n "${status_output}" ]]; then
  echo "Error: working tree is not clean. Commit or stash your changes before syncing upstream." >&2
  exit 1
fi

run() {
  echo "+ $*"
  if [[ "${DRY_RUN}" == "false" ]]; then
    "$@"
  fi
}

echo "Syncing upstream into local main and origin/main"
echo "Current branch: ${current_branch}"
echo "Dry run: ${DRY_RUN}"

run git fetch upstream

if [[ "${current_branch}" != "main" ]]; then
  run git checkout main
fi

run git merge --ff-only upstream/main
run git push origin main

echo
echo "Sync complete."
echo "Next step for feature branches:"
echo "  git checkout <your-feature-branch>"
echo "  git merge main"
