# Git (solo)

Always on, with no `paths` filter, because git discipline applies to every task. The project is in solo mode: one person's work, no pull requests.

- Commit on `{{DEFAULT_BRANCH}}`, one concern per commit, and push after each working session. There are no branches, and `guard.sh` is installed with `ALLOW_DEFAULT_BRANCH_PUSH=1` so the push is not queried.
- Review the unpushed commits before pushing: run the fresh-context review over `origin/{{DEFAULT_BRANCH}}..HEAD`, or over every commit when there is no remote yet, because the push is the last point where a defect is cheap to fix.
- Run `sh scripts/check.sh` before the push. Force pushes, `--all`, `--mirror`, `git reset --hard` and `git clean -f` stay blocked.
- No remote yet is fine: commit and skip fetch and push. Ask early whether to add one, and create it private after one yes, because phone and cloud sessions start from the remote.
- Commit by path: name the files in `git add src/a.txt`, then `git commit`. Never `git commit -a` or `-am`, because a sweep picks up files another session left in the tree. `guard.sh` blocks both.
- The subject is imperative, about 50 characters, with no full stop. Add a type prefix such as `fix:` only when release tooling reads it, and follow the repo's own convention when it has one.
- Run git as `git -C /absolute/dir status` and write long messages to a file, because `cd dir && git ...` shapes trigger approval prompts.
- On any HTTP 403 or 429, "secondary rate limit" or "abuse detection" from git or the host's CLI, stop all git and host work and show the owner the exact error. A retry can turn a warning into a suspension.
