#!/bin/sh
# The local gate, run before a push, or before a pull request when the project reviews. The same steps as CI, in the same
# order, stopping at the first failure. Prints PASS, FAIL or SKIP per step. A step whose command is empty or an unreplaced
# placeholder is a SKIP, so a project with no linter leaves the value empty and the gate still runs. When every step is a
# SKIP, nothing was checked, so the gate fails with "No checks ran" instead of passing. Every variable is read as
# ${VAR:-}, so deleting an assignment line is safe under `set -u`.
# Run it from anywhere inside the repository: `sh scripts/check.sh`.
# > ADAPT: the commands are filled from the stack at install. Examples: Node or TypeScript: install `npm ci`, typecheck
# `npx tsc --noEmit`, test `npm test`; Python: `pip install -r requirements.txt`, `mypy .`, `pytest`. Add a step for
# anything else the stack needs, such as a database reset followed by its data tests.
set -eu
cd "$(git rev-parse --show-toplevel)"

INSTALL_CMD="{{INSTALL_CMD}}"
TYPECHECK_CMD="{{TYPECHECK_CMD}}"
TEST_CMD="{{TEST_CMD}}"
LINT_CMD="{{LINT_CMD}}"
BUILD_CMD="{{BUILD_CMD}}"
DEFAULT_BRANCH="{{DEFAULT_BRANCH}}"
PH=$(printf '\173\173') # the two opening braces that mark an unreplaced placeholder
case $DEFAULT_BRANCH in "" | *"$PH"*) DEFAULT_BRANCH=main ;; esac

ran=0
step() {
  name=$1
  cmd=$2
  case $cmd in
    "" | *"$PH"*) echo "SKIP $name (no command configured)"; return 0 ;;
  esac
  if sh -c "$cmd"; then
    ran=$((ran + 1))
    echo "PASS $name"
  else
    echo "FAIL $name: $cmd" >&2
    exit 1
  fi
}

# Ends the run: a gate with no command filled in has checked nothing and must not say it passed.
finish() {
  if [ "$ran" -eq 0 ]; then
    echo "No checks ran: fill the commands in scripts/check.sh" >&2
    exit 1
  fi
  echo "All gates passed."
  exit 0
}

step install "${INSTALL_CMD:-}"
step typecheck "${TYPECHECK_CMD:-}"
step test "${TEST_CMD:-}"
step lint "${LINT_CMD:-}"
step build "${BUILD_CMD:-}"

# Secrets: no env file other than the example, no key-shaped string added. The base is the remote default branch when
# there is one (the unpushed commits), else, when committing on the default branch of a repo with no remote, the empty
# tree (every tracked file), else the local default branch.
if ! git rev-parse --verify --quiet HEAD >/dev/null; then
  echo "SKIP secrets (no commit yet)"
  finish
elif git rev-parse --verify --quiet "origin/$DEFAULT_BRANCH" >/dev/null; then
  range="origin/$DEFAULT_BRANCH...HEAD"
elif [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" = "$DEFAULT_BRANCH" ]; then
  range="$(git hash-object -t tree /dev/null) HEAD"
else
  range="$DEFAULT_BRANCH...HEAD"
fi
# shellcheck disable=SC2086
if git diff $range --name-only | grep -E '(^|/)\.env($|\.)' | grep -vE '\.env\.(example|sample|template)$'; then
  echo "FAIL secrets: an env file is in the diff." >&2
  exit 1
fi
# shellcheck disable=SC2086
if git diff $range | grep -E '^\+' | grep -E 'sk-[A-Za-z0-9_-]{20,}|sk_(live|test)_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}|ghp_[A-Za-z0-9]{36}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----'; then
  echo "FAIL secrets: a key-shaped string is in the diff." >&2
  exit 1
fi
echo "PASS secrets"
finish
