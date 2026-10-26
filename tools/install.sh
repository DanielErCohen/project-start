#!/bin/sh
# project-start installer.
# Usage: sh tools/install.sh --target DIR [--mode solo|orchestrator|human-review|issues-only]
#                            [--code] [--modules a,b,c]
#
# Copies core/files into DIR and modules/<name>/files for each named module.
# --code adds the module "code". The merge mode (default solo) sets the push
# flag in the installed guard, replaces {{MERGE_MODE}} in the installed
# markdown files, and picks one git rule (git-solo.md for solo, git-review.md
# for the others), installed as .claude/rules/git.md. The first install records
# the mode in DIR/project/.mode; a later run without --mode reads it, and a
# different --mode stops with a message, because the mode is changed by hand.
# Then it applies each module's "## Append" lines and prints its "## Manual"
# steps. An existing file is never overwritten: the new version is written
# beside it as <file>.project-start and listed at the end. When two modules
# ship the same file, the second one's text is added to the first under a
# "## <module> additions" heading. A file listed in
# DIR/project/.installed is never copied again, even if you deleted it, so a
# module can be added later without bringing back what you dropped.
# DIR/project/.installed lists the files and DIR/project/.modules the modules;
# verify.sh reads both. POSIX sh, no network. Works with GNU and BSD tools and
# Git Bash.

set -u

die() {
  printf 'install: %s\n' "$1" >&2
  exit 2
}

usage() {
  cat <<'EOF'
Usage: sh tools/install.sh --target DIR [--mode MODE] [--code] [--modules a,b,c]

  --target DIR     project folder to install into (created if missing)
  --mode MODE      solo (default for a new project), orchestrator, human-review or
                   issues-only; a later run reads the mode recorded in project/.mode
  --code           add the module "code" (check script, rules, docs rule)
  --modules LIST   comma-separated module names, for example review,privacy
EOF
}

ROOT=$(cd "$(dirname "$0")/.." && pwd) || die "cannot find the project-start folder"

TARGET=""
CODE=0
MODULES=""
MODE=""
while [ $# -gt 0 ]; do
  case $1 in
    --target)
      [ $# -ge 2 ] || die "--target needs a folder"
      TARGET=$2
      shift 2
      ;;
    --mode)
      [ $# -ge 2 ] || die "--mode needs solo, orchestrator, human-review or issues-only"
      MODE=$2
      shift 2
      ;;
    --code)
      CODE=1
      shift
      ;;
    --modules)
      [ $# -ge 2 ] || die "--modules needs a comma-separated list"
      MODULES=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "unknown argument: $1"
      ;;
  esac
done

[ -n "$TARGET" ] || {
  usage >&2
  die "--target is required"
}
case $MODE in
  "" | solo | orchestrator | human-review | issues-only) ;;
  *) die "bad --mode: $MODE (solo, orchestrator, human-review or issues-only)" ;;
esac
[ -d "$ROOT/core/files" ] || die "missing $ROOT/core/files"

# Validate every module before copying anything. "code" comes first.
MODLIST=""
if [ "$CODE" -eq 1 ]; then
  MODLIST=" code"
fi
if [ -n "$MODULES" ]; then
  set -f
  OLDIFS=$IFS
  IFS=,
  # shellcheck disable=SC2086
  set -- $MODULES
  IFS=$OLDIFS
  set +f
  for m in "$@"; do
    [ -n "$m" ] || continue
    case $m in
      *[!a-z-]*) die "bad module name: $m (lowercase letters and hyphens only)" ;;
    esac
    case "$MODLIST " in
      *" $m "*) continue ;;
    esac
    MODLIST="$MODLIST $m"
  done
fi
for m in $MODLIST; do
  [ -d "$ROOT/modules/$m" ] || die "no such module: $m"
done

mkdir -p "$TARGET" || die "cannot create $TARGET"
TARGET=$(cd "$TARGET" && pwd) || die "cannot enter $TARGET"
case "$TARGET/" in
  "$ROOT"/*) die "the target must be outside the project-start folder" ;;
esac

# The mode is recorded at the first install and read back afterwards.
MODEFILE=$TARGET/project/.mode
PREVMODE=""
[ -f "$MODEFILE" ] && PREVMODE=$(tr -d '\r' <"$MODEFILE" | head -n 1 | tr -d ' ')
if [ -n "$PREVMODE" ]; then
  if [ -n "$MODE" ] && [ "$MODE" != "$PREVMODE" ]; then
    die "this project is in mode $PREVMODE (project/.mode), and --mode $MODE was given; change the mode by hand: set the mode line in project/working-agreement.md and the text in project/.mode, set ALLOW_DEFAULT_BRANCH_PUSH in .claude/hooks/guard.sh (1 for solo, 0 for the others), and replace .claude/rules/git.md with git-solo.md (solo) or git-review.md (the others) from modules/code/files/.claude/rules/. Or run again without --mode to keep $PREVMODE."
  fi
  MODE=$PREVMODE
fi
[ -n "$MODE" ] || MODE=solo

TMP=${TMPDIR:-/tmp}/ps-install.$$
mkdir -p "$TMP" || die "cannot create a temp folder"
trap 'rm -rf "$TMP"' EXIT
trap 'exit 130' INT TERM

PREV=$TARGET/project/.installed
: >"$TMP/new"
: >"$TMP/conf"
COPIED=0
MERGED=0
SAME=0
KEPT=0

was_installed() {
  [ -f "$PREV" ] && tr -d '\r' <"$PREV" | grep -qxF -- "$1"
}

# fixup REL FILE: mode-dependent edits to a file this run just wrote.
fixup() {
  case $1 in
    *.md)
      if grep -q '{{MERGE_MODE}}' "$2" 2>/dev/null; then
        sed "s/{{MERGE_MODE}}/$MODE/g" "$2" >"$TMP/fix" && cat "$TMP/fix" >"$2"
      fi
      ;;
    .claude/hooks/guard.sh)
      if [ "$MODE" = solo ]; then
        sed 's/^ALLOW_DEFAULT_BRANCH_PUSH=0$/ALLOW_DEFAULT_BRANCH_PUSH=1/' "$2" >"$TMP/fix" && cat "$TMP/fix" >"$2"
      fi
      ;;
  esac
}

copy_tree() {
  src=$1
  modname=$2
  [ -d "$src" ] || return 0
  find "$src" -type f ! -name .DS_Store ! -name '*.project-start' | sort >"$TMP/files"
  while IFS= read -r f; do
    rel=${f#"$src"/}
    # Exactly one git rule is installed, under the name git.md.
    case $rel in
      .claude/rules/git-solo.md)
        [ "$MODE" = solo ] || continue
        rel=.claude/rules/git.md
        ;;
      .claude/rules/git-review.md)
        [ "$MODE" != solo ] || continue
        rel=.claude/rules/git.md
        ;;
    esac
    dest=$TARGET/$rel
    if was_installed "$rel"; then
      # Listed by an earlier run: never copy it again, even if it was deleted.
      KEPT=$((KEPT + 1))
      printf '%s\n' "$rel" >>"$TMP/new"
    elif grep -qxF -- "$rel" "$TMP/new"; then
      # A file from another part of this run owns the path: add this module's text below it.
      out=$dest
      if grep -qxF -- "$rel" "$TMP/conf" && [ -f "$dest.project-start" ]; then
        out=$dest.project-start
      fi
      cp "$f" "$TMP/extra"
      fixup "$rel" "$TMP/extra"
      {
        printf '\n## %s additions\n\n' "$modname"
        sed '1{/^# /d;}' "$TMP/extra"
      } >>"$out"
      MERGED=$((MERGED + 1))
    elif [ -e "$dest" ] || [ -L "$dest" ]; then
      if cmp -s "$f" "$dest"; then
        SAME=$((SAME + 1))
        printf '%s\n' "$rel" >>"$TMP/new"
      else
        cp "$f" "$dest.project-start"
        fixup "$rel" "$dest.project-start"
        printf '%s\n' "$rel" >>"$TMP/new"
        printf '%s\n' "$rel" >>"$TMP/conf"
      fi
    else
      mkdir -p "$(dirname "$dest")"
      cp "$f" "$dest"
      fixup "$rel" "$dest"
      case $rel in
        *.sh) chmod +x "$dest" 2>/dev/null || true ;;
      esac
      COPIED=$((COPIED + 1))
      printf '%s\n' "$rel" >>"$TMP/new"
    fi
  done <"$TMP/files"
}

copy_tree "$ROOT/core/files" core
for m in $MODLIST; do
  copy_tree "$ROOT/modules/$m/files" "$m"
done

mkdir -p "$TARGET/project"
{
  [ -f "$PREV" ] && tr -d '\r' <"$PREV"
  cat "$TMP/new"
} | grep -v '^$' | sort -u >"$TMP/all"
cp "$TMP/all" "$PREV"
TOTAL=$(wc -l <"$TMP/all" | tr -d ' ')

# Record the modules, across runs, for verify.sh.
{
  [ -f "$TARGET/project/.modules" ] && tr -d '\r' <"$TARGET/project/.modules"
  for m in $MODLIST; do printf '%s\n' "$m"; done
} | grep -v '^$' | sort -u >"$TMP/mods"
cp "$TMP/mods" "$TARGET/project/.modules"

# Record the mode at the first install.
[ -f "$MODEFILE" ] || printf '%s\n' "$MODE" >"$MODEFILE"

printf 'Installed into: %s (merge mode: %s)\n' "$TARGET" "$MODE"
printf '  new files: %s, already identical: %s, kept from an earlier run: %s\n' "$COPIED" "$SAME" "$KEPT"
printf '  files listed in project/.installed: %s\n' "$TOTAL"
if [ "$MERGED" -gt 0 ]; then
  printf '  files two modules ship, the second added under "## <module> additions": %s\n' "$MERGED"
fi

if [ -s "$TMP/conf" ]; then
  printf '\nThese files already existed and were not changed. The new version sits beside each one.\nMerge by hand, then delete the .project-start file:\n'
  sort -u "$TMP/conf" | while IFS= read -r rel; do
    printf '  %s  (new version: %s.project-start)\n' "$rel" "$rel"
  done
fi

# section MODULE.md NAME: the lines under "## NAME", up to the next heading or
# the Trigger, Adds or Skip when line. Blank lines and CRs dropped.
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

# trim TEXT: strip leading and trailing blanks.
trim() {
  printf '%s' "$1" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# append_md FILE TEXT: add "- TEXT" under the final "## Modules" heading,
# creating the heading when missing. Returns 1 when the line is already there.
append_md() {
  grep -qxF -- "- $2" "$1" 2>/dev/null && return 1
  ADD="- $2" awk '
    { L[NR] = $0 }
    END {
      add = ENVIRON["ADD"]
      m = 0
      for (i = 1; i <= NR; i++) if (L[i] ~ /^## +Modules[ \t]*$/) m = i
      if (m == 0) {
        for (i = 1; i <= NR; i++) print L[i]
        if (NR > 0 && L[NR] != "") print ""
        print "## Modules"
        print ""
        print add
        exit
      }
      e = NR + 1
      for (i = m + 1; i <= NR; i++) if (L[i] ~ /^#/) { e = i; break }
      last = e - 1
      while (last > m && L[last] == "") last--
      for (i = 1; i <= last; i++) print L[i]
      if (last == m) print ""
      print add
      for (i = last + 1; i <= NR; i++) print L[i]
    }
  ' "$1" >"$TMP/md.out" && cat "$TMP/md.out" >"$1"
  return 0
}

# append_plain FILE TEXT: add TEXT as a line. Returns 1 when already there.
append_plain() {
  grep -qxF -- "$2" "$1" 2>/dev/null && return 1
  if [ -s "$1" ] && [ -n "$(tail -c 1 "$1")" ]; then
    printf '\n' >>"$1"
  fi
  printf '%s\n' "$2" >>"$1"
  return 0
}

if [ -n "$MODLIST" ]; then
  ADDED=0
  PRESENT=0
  NOFILE=0
  : >"$TMP/manual"
  for m in $MODLIST; do
    mf=$ROOT/modules/$m/MODULE.md
    if [ ! -f "$mf" ]; then
      printf '(no MODULE.md found for %s)\n' "$m" >>"$TMP/manual"
      continue
    fi
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
      out=$TARGET/$p
      # A file that is waiting for a hand merge gets the line in its new copy.
      if grep -qxF -- "$p" "$TMP/conf" && [ -f "$out.project-start" ]; then
        out=$out.project-start
      fi
      if [ ! -f "$out" ]; then
        NOFILE=$((NOFILE + 1))
        printf 'not applied (%s is not installed): %s\n' "$p" "$t" >>"$TMP/manual"
        continue
      fi
      case $p in
        .gitignore | */.gitignore) append_plain "$out" "$t" ;;
        *) append_md "$out" "$t" ;;
      esac
      if [ $? -eq 0 ]; then ADDED=$((ADDED + 1)); else PRESENT=$((PRESENT + 1)); fi
    done <"$TMP/append"
    section "$mf" Manual >"$TMP/msec"
    if [ -s "$TMP/msec" ]; then
      printf '\n== %s ==\n' "$m" >>"$TMP/manual"
      cat "$TMP/msec" >>"$TMP/manual"
    fi
  done
  printf '\nModule lines: %s appended, %s already present, %s not applied.\n' "$ADDED" "$PRESENT" "$NOFILE"
  if [ -s "$TMP/manual" ]; then
    printf '\nManual steps (do these by hand):\n'
    cat "$TMP/manual"
  fi
fi

printf '\nNext: fill every {{TOKEN}}, rewrite every "> ADAPT:" passage, then run\n  sh "%s/tools/verify.sh" --target "%s"\n' "$ROOT" "$TARGET"
