#!/bin/sh
# Cases for guard.sh, with ALLOW_DEFAULT_BRANCH_PUSH off (the default) and on (solo work). Run with `sh guard.test.sh` from
# any folder: prints one line per failing case and exits 1 if any fails. Expected: 0 allowed with no output, 2 blocked, ask
# allowed with the PreToolUse "ask" JSON on stdout (the owner is asked). Every case runs
# under each JSON reader that works here (jq, python3, plain sed) where the reader can matter (quoting, newlines, paths,
# unreadable input), so the fallbacks stay honest, and under the first reader elsewhere to keep the run short. Set
# GUARD_TEST_FULL=1 to run every case under every reader. Add a case for every false positive or miss found in use.
here=$(cd "$(dirname "$0")" && pwd)
hook="$here/guard.sh"
hook_cur=$hook
unset CLAUDE_PROJECT_DIR
tmp=$(mktemp -d) && trap 'rm -rf "$tmp"' EXIT INT TERM
fails=0
total=0

# Two throwaway repositories: one on the default branch, one on a short branch.
repo_main="$tmp/on-main"
repo_feat="$tmp/on-feature"
for r in "$repo_main" "$repo_feat"; do
  mkdir -p "$r/db/migrations"
  git -C "$r" init -q -b main
  printf 'create table a (id int);\n' > "$r/db/migrations/001_a.sql"
  git -C "$r" add db/migrations/001_a.sql
  git -C "$r" -c user.email=t@example.com -c user.name=t commit -q -m init
done
git -C "$repo_feat" switch -q -c feat/x
# A migration added on the working branch only: it does not exist on main yet
printf 'create table b (id int);\n' > "$repo_feat/db/migrations/004_new.sql"
git -C "$repo_feat" add db/migrations/004_new.sql
git -C "$repo_feat" -c user.email=t@example.com -c user.name=t commit -q -m "add 004"

# A project with a nested repository in project/ (listed in SOLO_PATHS) and another in other/ (not listed)
repo_proj="$tmp/proj"
for r in "$repo_proj" "$repo_proj/project" "$repo_proj/other"; do
  mkdir -p "$r"
  git -C "$r" init -q -b main
  printf 'x\n' > "$r/a.txt"
  git -C "$r" add a.txt
  git -C "$r" -c user.email=t@example.com -c user.name=t commit -q -m init
done

# The solo variant of the hook: the same file with ALLOW_DEFAULT_BRANCH_PUSH set to 1, as the install does for solo work.
if ! grep -q '^ALLOW_DEFAULT_BRANCH_PUSH=[01]$' "$hook"; then echo "FAIL: ALLOW_DEFAULT_BRANCH_PUSH line not found in guard.sh"; exit 1; fi
hook_off="$tmp/guard-team.sh"
hook_on="$tmp/guard-solo.sh"
sed 's/^ALLOW_DEFAULT_BRANCH_PUSH=[01]$/ALLOW_DEFAULT_BRANCH_PUSH=0/' "$hook" > "$hook_off"
sed 's/^ALLOW_DEFAULT_BRANCH_PUSH=[01]$/ALLOW_DEFAULT_BRANCH_PUSH=1/' "$hook" > "$hook_on"
hook=$hook_off
hook_cur=$hook

# verdict <expected 0|2|ask> <exit code> <stdout>: 0 means allowed with no output, ask means allowed with the ask JSON
verdict() {
  case $1 in
    ask)
      [ "$2" = 0 ] || return 1
      case $3 in *'"permissionDecision":"ask"'*) return 0 ;; esac
      return 1 ;;
    0) [ "$2" = 0 ] && [ -z "$3" ] ;;
    *) [ "$2" = "$1" ] ;;
  esac
}

# check <expected 0|2|ask> <cwd> <command>: a Bash call
check() {
  want=$1 dir=$2 cmd=$3
  json=$(printf '%s\n' "$cmd" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'NR>1{printf "\\n"} {printf "%s",$0}')
  payload=$(printf '{"cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s"}}' "$dir" "$json")
  for tool in $ctools; do
    total=$((total + 1))
    out=$(printf '%s' "$payload" | GUARD_JSON_TOOL=$tool sh "$hook_cur" 2>/dev/null)
    got=$?
    if ! verdict "$want" "$got" "$out"; then
      echo "FAIL ($tool): expected $want, got $got${out:+ and output}: $cmd"
      fails=$((fails + 1))
    fi
  done
}

# edit <expected 0|2|ask> <tool name> <file path>: an Edit, Write or MultiEdit call; the content field holds text the hook must ignore
edit() {
  want=$1 name=$2 fpath=$(printf '%s' "$3" | sed 's/\\/\\\\/g')
  payload=$(printf '{"cwd":"%s","tool_name":"%s","tool_input":{"file_path":"%s","content":"git push -f and cat .env\\n"}}' "$repo_feat" "$name" "$fpath")
  for tool in $ctools; do
    total=$((total + 1))
    out=$(printf '%s' "$payload" | GUARD_JSON_TOOL=$tool sh "$hook_cur" 2>/dev/null)
    got=$?
    if ! verdict "$want" "$got" "$out"; then
      echo "FAIL ($tool): expected $want, got $got${out:+ and output}: $name $3"
      fails=$((fails + 1))
    fi
  done
}

# A reader counts only if it runs: jq and python3 are probed with a real parse, sed is always there.
tools=sed
printf '{"a":"b"}' | python3 -c 'import json,sys; json.load(sys.stdin)' >/dev/null 2>&1 && tools="python3 $tools"
printf '{"a":"b"}' | jq -r .a >/dev/null 2>&1 && tools="jq $tools"

# narrow: run the next cases under the first reader only; wide: under every reader
narrow() { if [ "${GUARD_TEST_FULL:-}" = 1 ]; then ctools=$tools; else ctools=${tools%% *}; fi; }
wide() { ctools=$tools; }

f=$repo_feat
m=$repo_main

wide
# Force pushes
check 2 "$f" 'git push --force'
check 2 "$f" 'git push -f origin feat/x'
check 2 "$f" 'git push -fu origin feat/x'
check 2 "$f" 'git push origin +feat/x'
check 2 "$f" 'git push --force=yes origin feat/x'
check 2 "$f" 'env X=1 git push -f'
check 2 "$f" 'time git push -f'
check 2 "$f" 'sudo -u root git push --force'
check 2 "$f" 'git -C ../other push -f'
check 2 "$f" 'git --no-pager push -f'
check 2 "$f" 'git fetch && git push --force'
check 2 "$f" 'bash -c "git push -f origin x"'
check 2 "$f" "sh -c 'git push --force'"
check 2 "$f" 'eval "git push -f"'
check 2 "$f" '/bin/bash -ec "git push -f"'
check 2 "$f" 'if true; then git push -f; fi'
check 0 "$f" 'git push --force-with-lease origin feat/x'
check 0 "$f" 'git push -u origin feat/x'
check 0 "$f" 'git push origin feat/x && ls -lf .'
check 0 "$f" 'git push --follow-tags origin feat/x'

narrow
# Pushes to the default branch
check ask "$f" 'git push origin main'
check ask "$f" 'git push -u origin main'
check ask "$f" 'git push origin HEAD:main'
check ask "$f" 'git push origin feat/x:main'
check ask "$f" 'git push origin HEAD:refs/heads/main'
check 2 "$f" 'git push --delete origin main'
check ask "$m" 'git push'
check ask "$m" 'git push origin'
check ask "$f" "git -C $m push"
check 0 "$f" 'git push'
check 0 "$f" 'git push origin'
check 0 "$f" 'git push origin feat/main-menu'
check 0 "$f" 'git push origin main-fix'
check 0 "$m" 'git push origin feat/y'

# Destructive resets and cleans
check 2 "$f" 'git reset --hard'
check 2 "$f" 'git reset --hard origin/main'
check 2 "$f" 'git -C ../x reset --hard HEAD~1'
check 2 "$f" 'git clean -fd'
check 2 "$f" 'git clean -fdx'
check 2 "$f" 'git clean --force'
check 2 "$f" 'git checkout -f main'
check 2 "$f" 'git checkout .'
check 2 "$f" 'git checkout -- .'
check 2 "$f" 'git restore .'
check 2 "$f" 'git switch --discard-changes main'
check 0 "$f" 'git clean -n'
check 0 "$f" 'git clean -fdn'
check 0 "$f" 'git reset --soft HEAD~1'
check 0 "$f" 'git reset HEAD file.txt'
check 0 "$f" 'git restore --staged .'
check 0 "$f" 'git restore src/a.txt'
check 0 "$f" 'git checkout -b feat/z'
check 0 "$f" 'git checkout -- src/a.txt'
check 0 "$f" 'git switch main'
check 0 "$f" 'git status'

# Cloud-production commands (the defaults in PROD_PATTERNS)
check ask "$f" 'terraform apply'
check ask "$f" 'terraform apply -auto-approve'
check ask "$f" 'terraform destroy'
check ask "$f" 'pulumi up --yes'
check ask "$f" 'kubectl apply -f x.yaml --context prod'
check ask "$f" 'kubectl delete pod x -n production'
check ask "$f" 'npx -y terraform apply'
check ask "$f" 'cd infra && terraform apply'
check ask "$f" 'foo deploy --prod'
check 0 "$f" 'terraform plan'
check 0 "$f" 'pulumi preview'
check 0 "$f" 'kubectl get pods --context staging'
check 0 "$f" 'foo deploy --preview'

check ask "$f" 'vercel --prod'
check ask "$f" 'vercel deploy --prod'
check ask "$f" 'vercel --prod --yes'
check ask "$f" 'npx vercel --prod'
check ask "$f" 'netlify deploy --prod'
check ask "$f" 'netlify deploy --dir=dist --prod'
check ask "$f" 'fly deploy'
check ask "$f" 'flyctl deploy --remote-only'
check ask "$f" 'railway up'
check ask "$f" 'railway up --detach'
check 0 "$f" 'vercel'
check 0 "$f" 'vercel dev'
check 0 "$f" 'vercel --prebuilt'
check 0 "$f" 'netlify deploy'
check 0 "$f" 'netlify status'
check 0 "$f" 'fly status'
check 0 "$f" 'flyctl logs'
check 0 "$f" 'railway logs'
check 0 "$f" 'railway status'

wide
# Harmless mentions: commit messages, echo, grep, heredoc bodies, comments in strings
check 0 "$f" 'git commit -m "never git push -f"'
check 0 "$f" 'git commit -m "docs: explain git reset --hard and terraform apply"'
check 0 "$f" 'git commit -m "fix; git push origin main is blocked"'
check 0 "$f" 'git commit -m "add guard against git clean -fd && git push --force"'
check 0 "$f" 'echo "git push --force"'
check 0 "$f" "echo 'terraform apply'"
check 0 "$f" 'printf "%s\n" "git reset --hard"'
check 0 "$f" 'grep -rn "git push --force" docs'
check 0 "$f" 'git log --grep="push -f"'
check 0 "$f" 'ls; echo "a | git push -f"'
check 0 "$f" "$(printf 'git commit -m "first line\ngit push -f\nthird line"')"
check 0 "$f" "$(printf 'cat > notes.md <<EOF\ngit push --force\nterraform apply\nEOF')"
check 0 "$f" "$(printf "cat <<'END'\ngit reset --hard\nEND")"
check 0 "$f" "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nFix the git push -f hook\n\nmentions git reset --hard and terraform apply\nEOF\n)"')"
check 2 "$f" "$(printf 'git commit -m "$(cat <<'"'"'EOF'"'"'\nmsg\nEOF\n)" && git push -f')"
check 2 "$f" "$(printf 'cat > notes.md <<EOF\nok\nEOF\ngit push -f')"

# Quoted branch names, HEAD and @ on the default branch, --all and --mirror
check ask "$f" 'git push origin "main"'
check ask "$f" "git push origin 'main'"
check ask "$f" 'git push origin "HEAD:main"'
check 2 "$f" 'git push origin "+feat/x"'
check ask "$m" 'git push origin HEAD'
check ask "$m" 'git push -u origin HEAD'
check ask "$m" 'git push origin @'
check 2 "$f" 'git push --all'
check 2 "$f" 'git push --all origin'
check 2 "$f" 'git push --mirror origin'
check 2 "$m" 'git push --mirror'
check 0 "$f" 'git push origin HEAD'
check 0 "$f" 'git push -u origin HEAD'
check 0 "$f" 'git push origin @'
check 0 "$f" 'git push origin "feat/x"'
check 0 "$f" 'git commit -m "git push --mirror and git push --all are blocked"'
check 0 "$f" 'echo "git push origin HEAD on main"'

narrow
# git commit -a in every form
check 2 "$f" 'git commit -a -m x'
check 2 "$f" 'git commit -am "msg"'
check 2 "$f" 'git commit -m x -a'
check 2 "$f" 'git commit -qam x'
check 2 "$f" 'git commit -sam x'
check 2 "$f" 'git commit --all -m x'
check 2 "$f" 'git add a.txt && git commit -am "x"'
check 2 "$f" 'git -C ../x commit -am "x"'
check 0 "$f" 'git commit -m x'
check 0 "$f" 'git commit -m "fix the -a flag"'
check 0 "$f" 'git commit -m "never use git commit -am"'
check 0 "$f" "git commit -m 'revert -am handling'"
check 0 "$f" 'git commit --amend --no-edit'
check 0 "$f" 'git commit --amend -m x'
check 0 "$f" 'git commit --allow-empty -m x'
check 0 "$f" 'git commit -n -m x'
check 0 "$f" 'git commit -S -m x'
check 0 "$f" 'git add src/a.txt'

# Bash reads of env files
check 2 "$f" 'cat .env'
check 2 "$f" 'cat .env.local'
check 2 "$f" 'cat .env.production'
check 2 "$f" 'cat config/.env'
check 2 "$f" 'cat "/app/.env"'
check 2 "$f" '/bin/cat .env'
check 2 "$f" 'sudo cat .env'
check 2 "$f" 'cat .env*'
check 2 "$f" 'cat .env.example .env'
check 2 "$f" 'cat < .env'
check 2 "$f" 'less .env'
check 2 "$f" 'more .env.staging'
check 2 "$f" 'head -n 3 .env'
check 2 "$f" 'tail -f .env.test'
check 2 "$f" 'source .env'
check 2 "$f" '. ./.env'
check 2 "$f" 'grep KEY .env'
check 2 "$f" 'grep -rn SECRET .env.production'
check 2 "$f" 'ls && cat .env'
check 0 "$f" 'cat .env.example'
check 0 "$f" 'cat .env.sample'
check 0 "$f" 'head -n 5 .env.template'
check 0 "$f" 'grep KEY .env.example'
check 0 "$f" 'grep -rn ".env" src'
check 0 "$f" 'grep -rn "process.env" src'
check 0 "$f" 'grep -n API_KEY src/config.ts'
check 0 "$f" 'cat docs/environment.md'
check 0 "$f" 'cat .envelope.txt'
check 0 "$f" 'ls -la .env'
check 0 "$f" 'echo .env'
check 0 "$f" 'echo "cat .env"'
check 0 "$f" 'git commit -m "docs: cat .env is blocked by the hook"'
check 0 "$f" 'source venv/bin/activate'
check 0 "$f" '. venv/bin/activate'
check 0 "$f" 'cat README.md'

wide
# Edit, Write and MultiEdit: env files, generated files, committed migrations
edit 2 Edit "$repo_feat/.env"
edit 2 Write ".env.local"
edit 2 Write "$repo_feat/app/.env.production"
edit 2 MultiEdit "/work/proj/.env.staging"
edit 0 Edit "$repo_feat/.env.example"
edit 0 Write ".env.sample"
edit 0 Write "config/.env.template"
edit 0 Write "docs/environment.md"
edit 0 Write ".envelope.txt"
edit 0 Edit "$repo_feat/src/app.ts"
edit 2 Edit "$repo_feat/package-lock.json"
edit 2 Write "web/pnpm-lock.yaml"
edit 2 Write "src/generated/api.ts"
edit 2 Write "src/__generated__/types.ts"
edit 2 Write "api.generated.ts"
edit 0 Write "src/generated-notes.md"
edit 0 Write "src/regenerate.ts"
edit 2 Edit "$repo_feat/db/migrations/001_a.sql"
edit 2 MultiEdit "$repo_main/db/migrations/001_a.sql"
edit 0 Write "$repo_feat/db/migrations/002_b.sql"
edit 0 Write "$repo_feat/db/migrations/new/003_c.sql"
edit 0 Write "$repo_feat/db/schema-notes.md"

narrow
# Solo: the same hook with ALLOW_DEFAULT_BRANCH_PUSH=1 allows pushing the default branch and nothing else
hook_cur=$hook_on
check 0 "$m" 'git push'
check 0 "$m" 'git push origin'
check 0 "$m" 'git push origin main'
check 0 "$m" 'git push -u origin main'
check 0 "$m" 'git push origin "main"'
check 0 "$m" 'git push origin HEAD'
check 0 "$m" 'git push origin HEAD:main'
check 0 "$f" 'git push origin feat/x'
check 0 "$m" 'git commit -m "add a"'
check 2 "$m" 'git push -f origin main'
check 2 "$m" 'git push origin +main'
check 2 "$m" 'git push --delete origin main'
check 2 "$m" 'git push origin :main'
check 2 "$m" 'git push --all'
check 2 "$m" 'git push --mirror'
check 2 "$m" 'git commit -am x'
check 2 "$m" 'git reset --hard'
check 2 "$m" 'git clean -fd'
check 2 "$m" 'cat .env'
check ask "$m" 'terraform apply'
check 0 "$m" 'git commit -m "git push origin main now works"'
edit 2 Write "$m/.env"
edit 2 Edit "$m/db/migrations/001_a.sql"
hook_cur=$hook
check ask "$m" 'git push origin main'
check ask "$m" 'git push origin HEAD'
check ask "$m" 'git push'

narrow
# Migration-apply and release commands ask the owner (item: new patterns)
check ask "$f" 'alembic upgrade head'
check ask "$f" 'alembic downgrade -1'
check ask "$f" 'prisma migrate deploy'
check ask "$f" 'npx prisma migrate deploy'
check ask "$f" 'supabase db push'
check ask "$f" 'npx supabase db push --linked'
check ask "$f" 'railway run npm start'
check ask "$f" 'railway down'
check ask "$f" 'glab mr merge 12'
check ask "$f" 'glab release create v1.0.0'
check ask "$f" 'gh pr merge 4 --admin'
check ask "$f" 'gh pr merge 4 --squash --admin'
check ask "$f" 'cargo publish'
check ask "$f" 'cargo +nightly publish'
check ask "$f" 'cargo +1.80.0 publish --allow-dirty'
check ask "$f" 'kubectl exec -it web -n prod -- sh'
check ask "$f" 'kubectl get pods && kubectl delete pod x -n prod'
check ask "$m" 'git push origin main && terraform apply'
check 0 "$f" 'alembic revision -m x'
check 0 "$f" 'alembic current'
check 0 "$f" 'prisma migrate dev'
check 0 "$f" 'prisma migrate status'
check 0 "$f" 'supabase db diff'
check 0 "$f" 'supabase start'
check 0 "$f" 'glab mr view 3'
check 0 "$f" 'glab release list'
check 0 "$f" 'gh pr merge 4 --squash'
check 0 "$f" 'gh pr view 4'
check 0 "$f" 'cargo build'
check 0 "$f" 'cargo +nightly build'
check 0 "$f" 'cargo publish --dry-run'
check 0 "$f" 'cargo +nightly publish --dry-run'
check 0 "$f" 'glab release view v1'
check ask "$f" 'cargo publish --allow-dirty'
check 0 "$f" 'echo "alembic upgrade head and railway down"'
check 0 "$f" 'git commit -m "docs: supabase db push needs approval"'
# Read-only kubectl against production passes
check 0 "$f" 'kubectl get pods -n production'
check 0 "$f" 'kubectl -n production get pods'
check 0 "$f" 'kubectl get pods --context prod'
check 0 "$f" 'kubectl describe pod web --context prod -n production'
check 0 "$f" 'kubectl logs web -n prod'
check 0 "$f" 'kubectl --context prod logs web'
# A block still wins over an ask in the same call
check 2 "$f" 'terraform apply && git push -f'
check 2 "$f" 'git push origin main && git reset --hard'
check 2 "$f" 'vercel --prod; cat .env'

# Example env files: reading them, and copying them into place, passes; reading the real file stays blocked
check 0 "$f" 'cat .env.example > .env'
check 0 "$f" 'cat .env.example >> .env.local'
check 0 "$f" 'cat .env.example >.env'
check 0 "$f" 'cat .env.sample 1> .env'
check 0 "$f" 'head -n 3 .env.template > .env.local'
check 0 "$f" 'cat .env.example | sed s/x/y/'
check 2 "$f" 'cat .env > backup.txt'
check 2 "$f" 'cat .env.example .env > all.txt'
check 2 "$f" 'cat < .env'
check 2 "$f" 'cat .envrc'

wide
# Backslash paths (Windows): read as slashes
check 2 "$f" 'cat config\.env'
check 2 "$f" 'cat C:\proj\.env'
check 2 "$f" 'cat C:\proj\.env.production'
check 0 "$f" 'cat C:\proj\.env.example'
check 0 "$f" 'cat C:\proj\src\app.ts'
edit 2 Write 'C:\proj\.env'
edit 2 Write 'C:\proj\.envrc'
edit 2 Edit 'C:\proj\src\generated\api.ts'
edit 2 Edit 'C:\proj\package-lock.json'
edit 0 Write 'C:\proj\.env.example'
edit 0 Edit 'C:\proj\src\app.ts'

# Migrations: blocked when the file exists on the default branch, editable when it exists only on this branch
edit 2 Edit "db/migrations/001_a.sql"
edit 2 Edit "./db/migrations/001_a.sql"
edit 0 Edit "$repo_feat/db/migrations/004_new.sql"
edit 0 Write "db/migrations/004_new.sql"
edit 0 Edit "$tmp/nonexistent/migrations/001_a.sql"

narrow
# SOLO_PATHS: pushes from a nested repository listed there count as solo, the project repository does not
p=$repo_proj
check 0 "$p" 'git -C project push'
check 0 "$p" 'git -C project push origin main'
check 0 "$p" 'git -C project push -u origin HEAD'
check 0 "$p" "git -C $p/project push origin main"
check ask "$p" 'git push origin main && git -C project push'
check ask "$p" 'git push origin main'
check ask "$p" 'git push'
check ask "$p" 'git -C other push origin main'
check ask "$p" 'git -C other push'
check 2 "$p" 'git -C project push -f origin main'
check 2 "$p" 'git -C project push --delete origin main'
check 2 "$p" 'git -C project push origin :main'
check 2 "$p" 'git -C project push --all'
check 2 "$p" 'git -C project push --mirror'
check 2 "$p" 'git -C project commit -am x'
# From inside project/, the project root comes from CLAUDE_PROJECT_DIR
check ask "$p/project" 'git push origin main'
CLAUDE_PROJECT_DIR=$p
export CLAUDE_PROJECT_DIR
check 0 "$p/project" 'git push origin main'
check 0 "$p/project" 'git push'
check ask "$p/other" 'git push origin main'
check ask "$p" 'git push origin main'
unset CLAUDE_PROJECT_DIR
# With SOLO_PATHS empty, the nested repository is like any other
hook_nosolo="$tmp/guard-nosolo.sh"
sed 's/^SOLO_PATHS="project"$/SOLO_PATHS=""/' "$hook" > "$hook_nosolo"
if cmp -s "$hook" "$hook_nosolo"; then echo "FAIL: SOLO_PATHS=\"project\" line not found in guard.sh"; exit 1; fi
hook_cur=$hook_nosolo
check ask "$p" 'git -C project push origin main'
hook_cur=$hook

narrow
# Early exit: a Bash call with no guarded word never reaches the command parser; one with a guarded word does
hook_early="$tmp/guard-early.sh"
awk '/^quick_hit\(\) \{/ { print "check_bash() { block reached; }" } { print }' "$hook" > "$hook_early"
if cmp -s "$hook" "$hook_early"; then echo "FAIL: quick_hit not found in guard.sh"; exit 1; fi
hook_cur=$hook_early
check 0 "$f" 'ls -la'
check 0 "$f" 'npm test'
check 0 "$f" 'echo hello > out.txt'
check 2 "$f" 'git status'
check 2 "$f" 'cat .env.example'
check 2 "$f" 'terraform plan'
check 2 "$f" 'kubectl get pods'
check 2 "$f" 'foo deploy --preview'
hook_cur=$hook
# A line the project adds to PROD_PATTERNS is guarded without touching anything else
hook_extra="$tmp/guard-extra.sh"
awk '/^PROD_PATTERNS=/ { print; print "mytool +ship( |$)"; next } { print }' "$hook" > "$hook_extra"
hook_cur=$hook
check 0 "$f" 'mytool ship'
hook_cur=$hook_extra
check ask "$f" 'mytool ship'
check ask "$f" 'npx mytool ship'
check 0 "$f" 'mytool status'
hook_cur=$hook

# The ask output is the documented PreToolUse JSON, whatever the command text holds
ask_json=$(printf '%s' '{"cwd":".","tool_input":{"command":"terraform apply -var \"q=1\""}}' | GUARD_JSON_TOOL=${tools%% *} sh "$hook" 2>/dev/null)
total=$((total + 1))
case $ask_json in
  '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"'*'"}}') ;;
  *) echo "FAIL: ask output has the wrong shape: $ask_json"; fails=$((fails + 1)) ;;
esac
for reader in $tools; do
  case $reader in
    jq)
      total=$((total + 1))
      printf '%s' "$ask_json" | jq -e '.hookSpecificOutput | .hookEventName == "PreToolUse" and .permissionDecision == "ask" and (.permissionDecisionReason | length > 0)' >/dev/null 2>&1 ||
        { echo "FAIL (jq): ask output is not the expected JSON: $ask_json"; fails=$((fails + 1)); } ;;
    python3)
      total=$((total + 1))
      printf '%s' "$ask_json" | python3 -c 'import json,sys
o = json.load(sys.stdin)["hookSpecificOutput"]
sys.exit(0 if o["hookEventName"] == "PreToolUse" and o["permissionDecision"] == "ask" and o["permissionDecisionReason"] else 1)' >/dev/null 2>&1 ||
        { echo "FAIL (python3): ask output is not the expected JSON: $ask_json"; fails=$((fails + 1)); } ;;
  esac
done
# A blocked call prints nothing on stdout, and an allowed call prints nothing at all
total=$((total + 1))
blocked_out=$(printf '%s' '{"cwd":".","tool_input":{"command":"git push -f"}}' | GUARD_JSON_TOOL=${tools%% *} sh "$hook" 2>/dev/null)
[ -z "$blocked_out" ] || { echo "FAIL: a blocked call wrote to stdout: $blocked_out"; fails=$((fails + 1)); }

# Fail closed: input that is not empty but yields no command or file path (a missing or broken JSON reader) is blocked;
# empty input is not a tool call and passes
for tool in $tools; do
  for bad in 'not json at all' '{"tool_input":{}}' '{"tool_input":{"command":""}}' '{"tool_input":{"file_path":""}}' '{"tool_name":"Write"}'; do
    total=$((total + 1))
    printf '%s' "$bad" | GUARD_JSON_TOOL=$tool sh "$hook" >/dev/null 2>&1
    got=$?
    if [ "$got" != 2 ]; then echo "FAIL ($tool): expected 2, got $got: unreadable input $bad"; fails=$((fails + 1)); fi
  done
  total=$((total + 1))
  printf '' | GUARD_JSON_TOOL=$tool sh "$hook" >/dev/null 2>&1
  got=$?
  if [ "$got" != 0 ]; then echo "FAIL ($tool): expected 0, got $got: empty input"; fails=$((fails + 1)); fi
done
# A reader that cannot run: python3 forced but replaced by a stub that prints nothing
stub="$tmp/stub"; mkdir -p "$stub"; printf '#!/bin/sh\nexit 1\n' > "$stub/python3"; chmod +x "$stub/python3"
total=$((total + 1))
printf '{"tool_input":{"command":"ls"}}' | PATH="$stub:$PATH" GUARD_JSON_TOOL=python3 sh "$hook" >/dev/null 2>&1
got=$?
if [ "$got" != 2 ]; then echo "FAIL (broken python3): expected 2, got $got"; fails=$((fails + 1)); fi
# With no GUARD_JSON_TOOL set, a python3 that cannot run is skipped and the call is still judged
total=$((total + 1))
printf '{"cwd":".","tool_input":{"command":"git push -f"}}' | PATH="$stub:$PATH" sh "$hook" >/dev/null 2>&1
got=$?
if [ "$got" != 2 ]; then echo "FAIL (auto-detect with broken python3): expected 2, got $got"; fails=$((fails + 1)); fi

narrow
# Plain commands pass
check 0 "$f" 'ls -la'
check 0 "$f" 'git diff origin/main...HEAD'
check 0 "$f" 'git add src/a.txt && git commit -m "Add a"'
check 0 "$f" 'echo hello > out.txt'
check 0 "$f" 'cat file | grep x'

[ "$fails" = 0 ] && echo "all $total checks pass (readers: $tools)"
exit $((fails > 0))
