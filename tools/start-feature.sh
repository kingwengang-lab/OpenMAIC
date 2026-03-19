#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false
PUSH=false
TOPIC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --push)
      PUSH=true
      shift
      ;;
    -*)
      echo "Error: unknown option '$1'" >&2
      exit 1
      ;;
    *)
      if [[ -n "${TOPIC}" ]]; then
        echo "Error: feature topic already provided: '${TOPIC}'" >&2
        exit 1
      fi
      TOPIC="$1"
      shift
      ;;
  esac
done

if [[ -z "${TOPIC}" ]]; then
  echo "Usage: ./tools/start-feature.sh <topic> [--push] [--dry-run]" >&2
  exit 1
fi

if [[ ! "${TOPIC}" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
  echo "Error: topic must match ^[a-z0-9][a-z0-9._-]*$" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: this command must be run inside a git repository." >&2
  exit 1
fi

branch="feature/${TOPIC}"

if git show-ref --verify --quiet "refs/heads/${branch}"; then
  echo "Error: local branch '${branch}' already exists." >&2
  exit 1
fi

if git ls-remote --exit-code --heads origin "${branch}" >/dev/null 2>&1; then
  echo "Error: remote branch '${branch}' already exists on origin." >&2
  exit 1
fi

run() {
  echo "+ $*"
  if [[ "${DRY_RUN}" == "false" ]]; then
    "$@"
  fi
}

echo "Preparing new feature branch '${branch}'"
echo "Dry run: ${DRY_RUN}"
echo "Push after create: ${PUSH}"

if [[ "${DRY_RUN}" == "true" ]]; then
  ./tools/sync-upstream.sh --dry-run
else
  run ./tools/sync-upstream.sh
fi

run git checkout -b "${branch}"

if [[ "${PUSH}" == "true" ]]; then
  run git push -u origin "${branch}"
fi

echo
echo "Feature branch ready: ${branch}"
if [[ "${PUSH}" == "false" ]]; then
  echo "Optional next step:"
  echo "  git push -u origin ${branch}"
fi
