#!/bin/sh
# PreToolUse hook for Bash, Edit, Write and MultiEdit. It blocks, asks the owner, or allows (the three answers are below).
# Wired in .claude/settings.json as `sh "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh"`, so it needs no exec bit.
#
# Two kinds of answer. Exit 2 with a message on stderr blocks the call: force pushes, --all and --mirror, deleting the
# default branch, git reset --hard, git clean -f, forced and whole-tree checkout and restore, git commit -a in every form,
# Bash reads of env files (cat, less, more, head, tail, source, `.`, grep) other than .env.example and its siblings, edits
# to env files and generated files, and edits to a migration that already exists on the default branch. Exit 0 with a
# PreToolUse "ask" JSON on stdout makes Claude Code ask the owner instead: the PROD_PATTERNS commands (deploys and
# migration applies) and, when the default branch changes only by merge, pushes to or from it. Other readers (awk, sed,
# cp) are not covered; the Read deny rules in settings.json cover the Read tool.
#
# Input: the tool call as JSON on stdin. JSON is read with jq when present, else python3 (only if it runs), else a plain
# sed extraction that decodes \" \\ \n \t only. Set GUARD_JSON_TOOL=jq|python3|sed to force one. Non-empty input with no
# readable command or file path is blocked, because a guard that cannot read a call cannot judge it (fail closed).
# Parsing is best effort and is no full shell parser: heredoc bodies are dropped, `sh -c "..."` and `eval "..."` are unwrapped,
# separators inside quotes are neutralised, and each simple command is checked on its own after leading wrappers (env,
# time, sudo, VAR=value and similar) are stripped. Only a command that starts with the guarded word is judged, so
# `echo "git push -f"` and a commit message that mentions a guarded command pass. A Bash call whose text holds none of
# the guarded words (git, .env, deploy, the first word of each PROD_PATTERNS line) exits 0 at once, so most calls cost
# one JSON read. Backslashes in file paths and env-file arguments are read as slashes (Windows).
# Cases: guard.test.sh (run with `sh guard.test.sh`).

# 1 when the project commits and pushes the default branch directly (solo work); 0 when the default branch changes only by
# merge, and then a push to or from it asks the owner. Force pushes, --all, --mirror and deleting the default branch stay
# blocked either way. Set at install.
ALLOW_DEFAULT_BRANCH_PUSH=0

# Repository folders, relative to the project root, whose pushes count as solo whatever the flag says: a second repository
# nested in the project, such as a private project/ folder with its own history. `git -C project push` and a push run
# from inside project/ are allowed to push their default branch. Space-separated; empty for none.
SOLO_PATHS="project"

DEFAULT_BRANCH="{{DEFAULT_BRANCH}}"
PH=$(printf '\173\173') # the two opening braces that mark an unreplaced placeholder
case $DEFAULT_BRANCH in "" | *"$PH"*) DEFAULT_BRANCH=main ;; esac

# Commands that change a live environment, one extended regular expression per line, matched at the start of a simple
# command (an npx, pnpm exec, yarn or similar runner prefix is allowed). A match asks the owner; it does not block. Start
# each line with a literal command word, because the early exit reads the first word of each line. Edit this list for the
# project. The block below covers common hosted deploys and migration applies and is active. Delete a line when the stack
# never uses that tool.
# > ADAPT: add the other commands that change a live environment in this stack. Examples, uncomment what applies:
#   Node or web hosting:  firebase +deploy
#   Database or backend:  supabase +(link|projects +delete)
#   Mobile:               eas(-cli)? +(build|submit|update)     fastlane +(release|deliver)
#   Python or Ruby:       twine +upload     cap +production +deploy
PROD_PATTERNS='
vercel +.*--prod(uction)?( |$)
netlify +deploy +.*--prod(uction)?( |$)
fly(ctl)? +deploy( |$)
railway +(up|run|down)( |$)
terraform +(apply|destroy)( |$)
pulumi +(up|destroy)( |$)
kubectl +.*(--context|--namespace|-n)[ =][^ ]*prod
alembic +(upgrade|downgrade)( |$)
prisma +migrate +deploy( |$)
supabase +db +push( |$)
glab +mr +merge( |$)
glab +release( |$)
gh +pr +merge +.*--admin( |$)
cargo( +[+][^ ]+)? +publish( |$)
[a-z]+ +deploy +.*--(prod|production)( |$)
'

# Commands that the PROD_PATTERNS would otherwise catch but that change nothing, same format: looking at production is
# allowed (the production-access rules govern what may be read), and so is a dry-run publish.
READ_ONLY_OK='
kubectl +((-n|--namespace|--context)[ =][^ ]+ +)*(get|describe|logs)( |$)
glab +release +(list|view|download)( |$)
cargo( +[+][^ ]+)? +publish +.*--dry-run( |$)
'

# Env files that may be read and edited: the committed template of the real one.
ENV_OK='.env.example .env.sample .env.template'

# Generated files: a path glob per line, matched against the full path. Change the source and regenerate instead.
# > ADAPT: list this project's generated outputs. Examples: Node or TypeScript: */src/generated/* */*.d.ts.map;
# Python: */*_pb2.py */_version.py; mobile: */Pods/* */build/generated/*; API clients: */openapi/generated/*.
GENERATED_PATHS='
*/package-lock.json
*/pnpm-lock.yaml
*/yarn.lock
*/poetry.lock
*/Cargo.lock
*/Gemfile.lock
*/generated/*
*/__generated__/*
*.generated.*
'

# Committed migrations: a path glob per line. Editing one that git already tracks is blocked; a new, untracked file is fine.
# > ADAPT: the folders where this project keeps schema migrations. Examples: */migrations/*.sql, */db/migrate/*.rb,
# */alembic/versions/*.py, */prisma/migrations/*/migration.sql.
MIGRATION_PATHS='
*/migrations/*
*/db/migrate/*
*/alembic/versions/*
'

block() {
  echo "Blocked: $1" >&2
  exit 2
}

# Remember the first reason to ask. The call is allowed to continue to the end so a later block still wins; main prints
# the ask JSON when nothing blocked.
ASK_REASON=
ask() {
  [ -n "$ASK_REASON" ] || ASK_REASON=$1
}

input=$(cat)

json_get() {
  tool=${GUARD_JSON_TOOL:-}
  if [ -z "$tool" ]; then
    if command -v jq >/dev/null 2>&1; then tool=jq
    elif python3 -c 'import json,sys' >/dev/null 2>&1; then tool=python3
    else tool=sed; fi
  fi
  case $tool in
    jq) printf '%s' "$input" | jq -r ".$1 // empty" 2>/dev/null ;;
    python3)
      printf '%s' "$input" | python3 -c 'import json,sys
d = json.load(sys.stdin)
for k in sys.argv[1].split("."):
    d = d.get(k) if isinstance(d, dict) else None
print(d if isinstance(d, str) else "")' "$1" 2>/dev/null ;;
    *)
      key=${1##*.}
      printf '%s' "$input" | tr -d '\n' |
        sed -nE 's/.*"'"$key"'" *: *"(([^"\\]|\\.)*)".*/\1/p' |
        sed -e 's/\\n/\
/g' -e 's/\\t/ /g' -e 's/\\"/"/g' -e 's/\\\\/\\/g' ;;
  esac
}

is_secret_env() {
  b=${1##*/}
  case $b in .env | .env.* | .envrc | '.env*') ;; *) return 1 ;; esac
  for ok in $ENV_OK; do [ "$b" = "$ok" ] && return 1; done
  return 0
}

get_cwd() {
  c=$(json_get cwd)
  [ -n "$c" ] || c=.
  printf '%s' "$c"
}

# 0 when the file already exists on the default branch (local or origin), so a migration written on the working branch
# stays editable until it merges.
on_default_branch() {
  p=$1
  case $p in /* | ?:/*) ;; *) p="$(get_cwd)/$p" ;; esac
  dir=${p%/*}
  [ -d "$dir" ] || return 1
  prefix=$(git -C "$dir" rev-parse --show-prefix 2>/dev/null) || return 1
  for ref in "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"; do
    git -C "$dir" cat-file -e "$ref:$prefix${p##*/}" 2>/dev/null && return 0
  done
  return 1
}

check_file() {
  path=$(printf '%s' "$1" | tr '\\' '/')
  base=${path##*/}

  if is_secret_env "$base"; then
    block "$base holds secrets. Edit .env.example instead; the owner sets real values."
  fi

  set -f
  old=$IFS
  IFS='
'
  for pat in $GENERATED_PATHS; do
    case $pat in "" | "#"*) continue ;; esac
    case "/$path" in
      $pat) IFS=$old; block "$base is generated. Change its source and run the project's generate command." ;;
    esac
  done
  for pat in $MIGRATION_PATHS; do
    case $pat in "" | "#"*) continue ;; esac
    case "/$path" in
      $pat)
        IFS=$old
        if on_default_branch "$path"; then
          block "$base is a migration that exists on $DEFAULT_BRANCH. Write a new migration instead of editing an applied one."
        fi
        IFS='
' ;;
    esac
  done
  IFS=$old
  set +f
}

# 0 when this repository's pushes count as solo: its top folder is one of SOLO_PATHS under the project root.
solo_path() {
  [ -n "$SOLO_PATHS" ] || return 1
  top=$(git -C "$1" rev-parse --show-toplevel 2>/dev/null) || return 1
  root=${CLAUDE_PROJECT_DIR:-}
  if [ -n "$root" ]; then root=$(cd "$root" 2>/dev/null && pwd -P); else root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); fi
  [ -n "$root" ] || return 1
  for sp in $SOLO_PATHS; do
    [ "$top" = "$root/$sp" ] && return 0
  done
  return 1
}

check_bash() {
  cmd=$1
  cwd=$(get_cwd)
  sq="'"

  # One simple command per line. Step 1 drops heredoc bodies, step 2 unwraps shells and eval, step 3 splits.
  segments=$(
    printf '%s\n' "$cmd" |
      awk -v sq="$sq" '
        BEGIN { hd = ""; re = "<<-?[ \t]*[\"" sq "]?[A-Za-z_][A-Za-z0-9_]*[\"" sq "]?" }
        {
          if (hd != "") { t = $0; sub(/^[ \t]+/, "", t); if (t == hd) hd = ""; next }
          line = $0
          if (match(line, re) && !(RSTART > 1 && substr(line, RSTART - 1, 1) == "<")) {
            d = substr(line, RSTART, RLENGTH)
            line = substr(line, 1, RSTART - 1) substr(line, RSTART + RLENGTH)
            gsub(/<<-?[ \t]*/, "", d); gsub("[\"" sq "]", "", d)
            hd = d
          }
          print line
        }' |
      sed -E \
        -e "s#(^|[^A-Za-z0-9_./-])([^ ]*/)?(bash|sh|zsh|dash|ksh)( +-[A-Za-z]+)* +-[A-Za-z]*c +\"([^\"]*)\"#\\1\\5#g" \
        -e "s#(^|[^A-Za-z0-9_./-])([^ ]*/)?(bash|sh|zsh|dash|ksh)( +-[A-Za-z]+)* +-[A-Za-z]*c +${sq}([^${sq}]*)${sq}#\\1\\5#g" \
        -e "s/(^|[^A-Za-z0-9_.-])eval +\"([^\"]*)\"/\\1\\2/g" \
        -e "s/(^|[^A-Za-z0-9_.-])eval +${sq}([^${sq}]*)${sq}/\\1\\2/g" |
      awk -v sq="$sq" '
        BEGIN {
          q = ""; buf = ""
          pat[1] = "^(time|env|command|exec|nice|nohup|sudo|timeout|then|do|else|elif|!)[ \t]+"
          pat[2] = "^-u[ \t]+[^ \t]+[ \t]+"
          pat[3] = "^-[A-Za-z]+[ \t]+([0-9]+[ \t]+)?"
          pat[4] = "^[0-9]+[smhd]?[ \t]+"
          pat[5] = "^[A-Za-z_][A-Za-z0-9_]*=(\"[^\"]*\"|" sq "[^" sq "]*" sq "|[^ \t]*)[ \t]+"
        }
        {
          n = length($0)
          for (i = 1; i <= n; i++) {
            c = substr($0, i, 1)
            if (q == "") {
              if (c == "\\") { buf = buf c substr($0, i + 1, 1); i++ }
              else if (c == "\"" || c == sq) { q = c; buf = buf c }
              else if (c ~ /[;&|(){}]/) buf = buf "\n"
              else buf = buf c
            } else {
              if (c == "\\" && q == "\"") { buf = buf c substr($0, i + 1, 1); i++ }
              else if (c == q) { q = ""; buf = buf c }
              else if (c ~ /[;&|(){}]/) buf = buf " "
              else buf = buf c
            }
          }
          buf = buf (q == "" ? "\n" : " ")
        }
        END {
          m = split(buf, segs, "\n")
          for (k = 1; k <= m; k++) {
            s = segs[k]; sub(/^[ \t]+/, "", s)
            do {
              changed = 0
              for (j = 1; j <= 5; j++) if (match(s, pat[j])) { s = substr(s, RLENGTH + 1); changed = 1; break }
            } while (changed)
            if (s != "") print s
          }
        }'
  )

  GITPFX='^git( +-[Cc] +[^ ]+| +--[a-z-]+(=[^ ]+)?)* +'
  RUNNER='((npx|bunx|pnpx|pnpm|npm|yarn|corepack|uvx)( +(exec|dlx|run|-y|--yes|--[a-z]+))* +)?'

  set -f
  while IFS= read -r seg; do
    [ -z "$seg" ] && continue

    if printf '%s' "$seg" | grep -Eq "$GITPFX"'[a-z-]+'; then
      gsub=$(printf '%s' "$seg" | sed -E "s/${GITPFX}([a-z-]+).*/\\3/")
      rest=$(printf '%s' "$seg" | sed -E "s/${GITPFX}[a-z-]+//")
      # The folder git acts on: the -C argument when given, else the session folder.
      target=$cwd
      prev=
      for w in $seg; do
        if [ "$prev" = "-C" ]; then
          case $w in "~"/*) w="$HOME/${w#\~/}" ;; esac
          case $w in /*) target=$w ;; *) target="$cwd/$w" ;; esac
        fi
        [ "$w" = push ] && break
        prev=$w
      done

      case $gsub in
        push)
          rest=$(printf '%s' "$rest" | tr -d "\"'")
          if printf '%s' "$rest" | grep -Eq ' (--force|--force=[^ ]*|-[a-zA-Z]*f[a-zA-Z]*)( |$)| \+[^ ]'; then
            block "force push. Use --force-with-lease, and only on your own branch."
          fi
          if printf '%s' "$rest" | grep -Eq ' (--all|--mirror)( |$)'; then
            block "git push --all and --mirror send every branch, the default branch included. Name the branch."
          fi
          allow=$ALLOW_DEFAULT_BRANCH_PUSH
          [ "$allow" = 1 ] || { solo_path "$target" && allow=1; }
          delete_flag=0
          printf '%s' "$rest" | grep -Eq ' (--delete|-d)( |$)' && delete_flag=1
          positional=0
          names_current=0
          for w in $rest; do
            case $w in -*) continue ;; esac
            positional=$((positional + 1))
            case $w in
              HEAD | @) names_current=1 ;;
              ":$DEFAULT_BRANCH" | ":refs/heads/$DEFAULT_BRANCH")
                block "deleting the default branch ($DEFAULT_BRANCH)." ;;
              "$DEFAULT_BRANCH" | "refs/heads/$DEFAULT_BRANCH" | *":$DEFAULT_BRANCH" | *":refs/heads/$DEFAULT_BRANCH")
                if [ "$delete_flag" = 1 ]; then
                  block "deleting the default branch ($DEFAULT_BRANCH)."
                fi
                if [ "$allow" != 1 ]; then
                  ask "push to the default branch ($DEFAULT_BRANCH). In this project it changes by merge; approve only if the owner wants a direct push."
                fi ;;
            esac
          done
          if [ "$allow" != 1 ] && { [ "$positional" -le 1 ] || [ "$names_current" = 1 ]; }; then
            current=$(git -C "$target" rev-parse --abbrev-ref HEAD 2>/dev/null)
            [ "$current" = "$DEFAULT_BRANCH" ] && ask "push from the default branch ($DEFAULT_BRANCH). In this project it changes by merge; work on a short branch unless the owner wants a direct push."
          fi ;;
        commit)
          flags=$(printf '%s' "$rest" | sed -E "s/\"[^\"]*\"//g; s/${sq}[^${sq}]*${sq}//g")
          if printf '%s' "$flags" | grep -Eq ' (-[a-zA-Z]*a[a-zA-Z]*|--all)( |$)'; then
            block "git commit -a sweeps in files another session or the editor left in the tree. Run git add <path>, then git commit."
          fi ;;
        reset)
          printf '%s' "$rest" | grep -Eq ' --hard( |$)' &&
            block "git reset --hard discards work. Ask the owner, or use git switch and git restore on named paths." ;;
        clean)
          if printf '%s' "$rest" | grep -Eq ' (-[a-zA-Z]*f[a-zA-Z]*|--force)( |$)' &&
             ! printf '%s' "$rest" | grep -Eq ' (-[a-zA-Z]*n[a-zA-Z]*|--dry-run)( |$)'; then
            block "git clean -f deletes untracked files for good. Run git clean -n first and ask the owner."
          fi ;;
        checkout | switch)
          if printf '%s' "$rest" | grep -Eq ' (-f|--force|--discard-changes)( |$)'; then
            block "forced checkout discards local changes."
          fi
          if [ "$gsub" = checkout ] && printf '%s' "$rest" | grep -Eq '( -- +| +)\.( |$)'; then
            block "git checkout . discards every local change. Name the paths."
          fi ;;
        restore)
          if printf '%s' "$rest" | grep -Eq ' \.( |$)' && ! printf '%s' "$rest" | grep -Eq ' (--staged|-S)( |$)'; then
            block "git restore . discards every local change. Name the paths."
          fi ;;
      esac
    fi

    first=${seg%% *}
    first=${first##*/}
    case $first in
      cat | less | more | head | tail | source | . | grep | egrep | fgrep)
        skip_pattern=0
        case $first in grep | egrep | fgrep) skip_pattern=1 ;; esac
        skip_next=0
        for w in $(printf '%s' "$seg" | tr -d "\"'" | tr '\\' '/' | cut -s -d ' ' -f 2-); do
          # A word after > or >> is a file being written, such as cat .env.example > .env, not one being read.
          if [ "$skip_next" = 1 ]; then skip_next=0; continue; fi
          case $w in
            '>' | '>>' | [0-9]'>' | [0-9]'>>' | '&>' | '&>>') skip_next=1; continue ;;
            '>'* | [0-9]'>'* | '&>'*) continue ;;
            -*) continue ;;
          esac
          if [ "$skip_pattern" = 1 ]; then skip_pattern=0; continue; fi
          if is_secret_env "$w"; then
            block "$w holds secrets. Read .env.example instead; the owner sets real values."
          fi
        done ;;
    esac

    old=$IFS
    IFS='
'
    ro=0
    for pat in $READ_ONLY_OK; do
      case $pat in "" | "#"*) continue ;; esac
      printf '%s' "$seg" | grep -Eq "^${RUNNER}(${pat})" && ro=1
    done
    if [ "$ro" = 0 ]; then
      for pat in $PROD_PATTERNS; do
        case $pat in "" | "#"*) continue ;; esac
        if printf '%s' "$seg" | grep -Eq "^${RUNNER}(${pat})"; then
          ask "production command. It changes a live environment, so the owner approves it each time."
          break
        fi
      done
    fi
    IFS=$old
  done <<EOF
$segments
EOF
  set +f
}

# 0 when the command text holds a guarded word: git, an env file, deploy, or the first word of a PROD_PATTERNS line.
quick_hit() {
  case $1 in *git* | *.env* | *deploy*) return 0 ;; esac
  set -f
  old=$IFS
  IFS='
'
  for pat in $PROD_PATTERNS; do
    case $pat in "" | "#"*) continue ;; esac
    w=${pat%%[ +(]*}
    w=${w%%\[*}
    [ -n "$w" ] || continue
    case $1 in *"$w"*) IFS=$old; set +f; return 0 ;; esac
  done
  IFS=$old
  set +f
  return 1
}

# An empty call is not a tool call.
[ -z "$(printf '%s' "$input" | tr -d ' \t\r\n')" ] && exit 0

cmd=$(json_get tool_input.command)
file=$(json_get tool_input.file_path)

if [ -z "$cmd" ] && [ -z "$file" ]; then
  block "no command or file path could be read from the tool call, so the guard cannot check it. Install jq or a working python3 (or set GUARD_JSON_TOOL=sed), then retry."
fi

[ -n "$file" ] && check_file "$file"
if [ -n "$cmd" ] && quick_hit "$cmd"; then
  check_bash "$cmd"
fi

if [ -n "$ASK_REASON" ]; then
  reason=$(printf '%s' "$ASK_REASON" | sed 's/\\/\\\\/g; s/"/\\"/g')
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
fi
exit 0
