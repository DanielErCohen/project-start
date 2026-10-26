#!/bin/sh
# project-start verifier.
# Usage: sh tools/verify.sh --target DIR     (or: sh tools/verify.sh DIR)
#
# Runs mechanical checks over the files listed in DIR/project/.installed and
# prints PASS, FAIL or SKIP per check: leftover tokens, ADAPT callouts and
# <placeholders>, paths, keys, links, shell syntax, the hook test, JSON, the
# push flag against the recorded merge mode, and the Append lines of each
# installed module. Exit code 1 when any check fails.
# POSIX sh, no network. Works with GNU and BSD tools and Git Bash.

set -u

die() {
  printf 'verify: %s\n' "$1" >&2
  exit 2
}

ROOT=$(cd "$(dirname "$0")/.." && pwd) || die "cannot find the project-start folder"

TARGET=""
while [ $# -gt 0 ]; do
  case $1 in
    --target)
      [ $# -ge 2 ] || die "--target needs a folder"
      TARGET=$2
      shift 2
      ;;
    -h | --help)
      printf 'Usage: sh tools/verify.sh --target DIR\n'
      exit 0
      ;;
    -*) die "unknown argument: $1" ;;
    *)
      TARGET=$1
      shift
      ;;
  esac
done

[ -n "$TARGET" ] || die "usage: sh tools/verify.sh --target DIR"
[ -d "$TARGET" ] || die "no such folder: $TARGET"
TARGET=$(cd "$TARGET" && pwd) || die "cannot enter $TARGET"
cd "$TARGET" || die "cannot enter $TARGET"
[ -f project/.installed ] || die "project/.installed is missing: run tools/install.sh first"

TMP=${TMPDIR:-/tmp}/ps-verify.$$
mkdir -p "$TMP" || die "cannot create a temp folder"
trap 'rm -rf "$TMP"' EXIT
trap 'exit 130' INT TERM

FAILS=0
CHECKS=0

# present: listed files that exist on disk (CR stripped, blanks dropped).
tr -d '\r' <project/.installed | grep -v '^$' >"$TMP/listed"
: >"$TMP/present"
MISSING=0
while IFS= read -r rel; do
  if [ -f "$rel" ]; then
    printf '%s\n' "$rel" >>"$TMP/present"
  else
    MISSING=$((MISSING + 1))
  fi
done <"$TMP/listed"

# report NAME FILE: FAIL with the lines in FILE, or PASS when FILE is empty.
report() {
  CHECKS=$((CHECKS + 1))
  if [ -s "$2" ]; then
    FAILS=$((FAILS + 1))
    printf 'FAIL  %s\n' "$1"
    head -n 10 "$2" | sed 's/^/        /'
    n=$(wc -l <"$2" | tr -d ' ')
    if [ "$n" -gt 10 ]; then
      printf '        ... %s more\n' $((n - 10))
    fi
  else
    printf 'PASS  %s\n' "$1"
  fi
}

skip() {
  CHECKS=$((CHECKS + 1))
  printf 'SKIP  %s (%s)\n' "$1" "$2"
}

# scan NAME PATTERN: extended-regex search over every present file.
scan() {
  : >"$TMP/out"
  while IFS= read -r rel; do
    grep -nHIE -e "$2" -- "$rel" >>"$TMP/out" 2>/dev/null
  done <"$TMP/present"
  report "$1" "$TMP/out"
}

printf 'Verifying %s (%s files listed, %s present)\n\n' "$TARGET" "$(wc -l <"$TMP/listed" | tr -d ' ')" "$(wc -l <"$TMP/present" | tr -d ' ')"

scan "no leftover {{TOKEN}}" '\{\{[A-Z][A-Z_]*\}\}'
scan "no leftover > ADAPT callout" '^(# )?> ADAPT'
scan "no absolute home paths" '(/Users/|/home/)[A-Za-z0-9_.-]|[A-Za-z]:\\Users\\'
scan "no key-shaped strings" 'sk-[A-Za-z0-9_-]{20,}|sk_(live|test)_[A-Za-z0-9]{16,}|github_pat_[A-Za-z0-9_]{20,}|gh[pousr]_[A-Za-z0-9]{36}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[abprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'

# Placeholders such as <amount per month> in installed project/ files.
: >"$TMP/out"
grep '^project/.*\.md$' "$TMP/present" >"$TMP/projmd"
while IFS= read -r rel; do
  grep -noE '<[a-z][a-z0-9-]*( [a-z][a-z0-9-]*)*>' -- "$rel" 2>/dev/null |
    grep -vE ':<(br|p|b|i|em|strong|code|pre|kbd|details|summary|sup|sub|img|a|hr|ul|ol|li|div|span|table|tr|td|th|h[1-6])>$' |
    sed "s|^|$rel:|" >>"$TMP/out"
done <"$TMP/projmd"
report "no leftover <placeholder> in project/ files" "$TMP/out"

# The push flag in the guard matches the merge mode in working-agreement.md.
MODEWORD='(solo|orchestrator|human-review|issues-only)'
if grep -qx '.claude/hooks/guard.sh' "$TMP/present" && grep -qx 'project/working-agreement.md' "$TMP/present"; then
  mode=$(grep -iE 'in force' project/working-agreement.md | grep -oE "\`$MODEWORD\`" | head -n 1 | tr -d '\`')
  [ -n "$mode" ] || mode=$(grep -iE 'merge mode' project/working-agreement.md | grep -oE "\`$MODEWORD\`" | head -n 1 | tr -d '\`')
  flag=$(grep -E '^ALLOW_DEFAULT_BRANCH_PUSH=[01]$' .claude/hooks/guard.sh | head -n 1 | sed 's/.*=//')
  : >"$TMP/out"
  if [ -z "$mode" ]; then
    skip "guard push flag matches the merge mode" "no merge mode recorded in project/working-agreement.md yet"
  elif [ -z "$flag" ]; then
    printf 'no ALLOW_DEFAULT_BRANCH_PUSH=0 or =1 line in .claude/hooks/guard.sh\n' >"$TMP/out"
    report "guard push flag matches the merge mode" "$TMP/out"
  else
    if [ "$mode" = solo ]; then want=1; else want=0; fi
    [ "$flag" = "$want" ] || printf 'merge mode %s needs ALLOW_DEFAULT_BRANCH_PUSH=%s, the guard has %s\n' "$mode" "$want" "$flag" >"$TMP/out"
    report "guard push flag matches the merge mode" "$TMP/out"
  fi
else
  skip "guard push flag matches the merge mode" "guard.sh or working-agreement.md not installed"
fi

# Every ## Append line of each installed module is present.
section() {
  tr -d '\r' <"$1" | awk -v want="$2" '
    /^#/ {
      if (p) exit
      t = $0
      sub(/^#+[ \t]*/, "", t)
      sub(/[ \t]+$/, "", t)
      if (tolower(t) == tolower(want)) p = 1
      next
    }
    p {
      low = tolower($0)
      if (low ~ /^[*_ ]*(skip when|trigger|adds)[*_ ]*:/) exit
      if ($0 ~ /[^ \t]/) print
    }
  '
}
trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}
if [ -f project/.modules ]; then
  : >"$TMP/out"
  NAPP=0
  tr -d '\r' <project/.modules | grep -v '^$' >"$TMP/mods"
  while IFS= read -r m; do
    mf=$ROOT/modules/$m/MODULE.md
    [ -f "$mf" ] || continue
    section "$mf" Append >"$TMP/append"
    while IFS= read -r line; do
      line=$(trim "$line")
      line=${line#- }
      case $line in
        *'|'*) ;;
        *) continue ;;
      esac
      p=$(trim "${line%%|*}")
      t=$(trim "${line#*|}")
      p=${p#\`}
      p=${p%\`}
      [ -n "$p" ] && [ -n "$t" ] || continue
      # A missing file is a dropped file; an unmerged copy is reported elsewhere.
      [ -f "$p" ] || continue
      [ -e "$p.project-start" ] && continue
      NAPP=$((NAPP + 1))
      case $p in
        .gitignore | */.gitignore) want=$t ;;
        *) want="- $t" ;;
      esac
      tr -d '\r' <"$p" | grep -qxF -- "$want" || printf '%s (module %s): missing "%s"\n' "$p" "$m" "$want" >>"$TMP/out"
    done <"$TMP/append"
  done <"$TMP/mods"
  report "module Append lines are present ($NAPP checked)" "$TMP/out"
else
  skip "module Append lines are present" "no project/.modules (installed by an older version)"
fi

# Unmerged .project-start files.
: >"$TMP/out"
while IFS= read -r rel; do
  [ -e "$rel.project-start" ] && printf '%s.project-start\n' "$rel" >>"$TMP/out"
done <"$TMP/listed"
report "no unmerged .project-start file" "$TMP/out"

# Broken relative markdown links.
: >"$TMP/out"
grep '\.md$' "$TMP/present" >"$TMP/mdfiles"
while IFS= read -r rel; do
  d=$(dirname "$rel")
  grep -o ']([^)]*)' "$rel" 2>/dev/null | sed 's/^](//; s/)$//' >"$TMP/links"
  while IFS= read -r l; do
    l=${l%% *}
    l=${l%%#*}
    case $l in
      '' | http:* | https:* | mailto:* | /* | *'{{'*) continue ;;
    esac
    [ -e "$d/$l" ] || printf '%s -> %s\n' "$rel" "$l" >>"$TMP/out"
  done <"$TMP/links"
done <"$TMP/mdfiles"
report "markdown links resolve" "$TMP/out"

# Shell scripts parse.
: >"$TMP/out"
grep '\.sh$' "$TMP/present" >"$TMP/shfiles"
if [ -s "$TMP/shfiles" ]; then
  while IFS= read -r rel; do
    if ! err=$(sh -n "$rel" 2>&1); then
      printf '%s: %s\n' "$rel" "$err" >>"$TMP/out"
    fi
  done <"$TMP/shfiles"
  report "shell scripts parse (sh -n)" "$TMP/out"
else
  skip "shell scripts parse (sh -n)" "no .sh files installed"
fi

# Hook test.
if grep -qx '.claude/hooks/guard.test.sh' "$TMP/present"; then
  CLAUDE_PROJECT_DIR=$TARGET
  export CLAUDE_PROJECT_DIR
  printf 'Running the hook test (it can take a few minutes)...\n'
  hooktest=.claude/hooks/guard.test.sh
  if grep -qx 'ALLOW_DEFAULT_BRANCH_PUSH=1' .claude/hooks/guard.sh 2>/dev/null; then
    # The test builds its own solo variant from a guard with the flag at 0,
    # so run it against a copy of the installed guard with the flag reset.
    mkdir -p "$TMP/hooks"
    cp .claude/hooks/guard.test.sh "$TMP/hooks/guard.test.sh"
    sed 's/^ALLOW_DEFAULT_BRANCH_PUSH=1$/ALLOW_DEFAULT_BRANCH_PUSH=0/' .claude/hooks/guard.sh >"$TMP/hooks/guard.sh"
    hooktest=$TMP/hooks/guard.test.sh
  fi
  sh "$hooktest" </dev/null >"$TMP/hooktest" 2>&1
  rc=$?
  if [ "$rc" -eq 0 ]; then
    : >"$TMP/out"
  else
    {
      printf 'guard.test.sh exited with code %s\n' "$rc"
      tail -n 10 "$TMP/hooktest"
    } >"$TMP/out"
  fi
  report "hook test passes" "$TMP/out"
  if [ "$rc" -eq 0 ]; then
    printf '        %s\n' "$(tail -n 1 "$TMP/hooktest")"
  fi
else
  skip "hook test passes" "no .claude/hooks/guard.test.sh installed"
fi

# JSON files parse. Detect a working Python by running it: a name can exist as
# a Windows Store stub that does nothing.
PY=""
for c in python3 python py; do
  if "$c" -c 'import json' >/dev/null 2>&1; then
    PY=$c
    break
  fi
done
grep '\.json$' "$TMP/present" >"$TMP/jsonfiles"
if [ ! -s "$TMP/jsonfiles" ]; then
  skip "settings JSON parses" "no .json files installed"
elif [ -z "$PY" ]; then
  skip "settings JSON parses" "no working python3, python or py found"
else
  : >"$TMP/out"
  while IFS= read -r rel; do
    if ! err=$("$PY" -c 'import json,sys; json.load(open(sys.argv[1], encoding="utf-8"))' "$rel" 2>&1); then
      printf '%s: %s\n' "$rel" "$(printf '%s' "$err" | tail -n 1)" >>"$TMP/out"
    fi
  done <"$TMP/jsonfiles"
  report "settings JSON parses" "$TMP/out"
fi

printf '\n'
if [ "$MISSING" -gt 0 ]; then
  printf 'Note: %s listed files are not on disk (removed on purpose, or missing).\n' "$MISSING"
fi
if [ "$FAILS" -gt 0 ]; then
  printf '%s of %s checks failed.\n' "$FAILS" "$CHECKS"
  exit 1
fi
printf 'All %s checks passed or skipped.\n' "$CHECKS"
exit 0
