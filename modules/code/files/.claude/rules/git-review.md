# Git (review)

Always on, with no `paths` filter, because git discipline applies to every task. Someone other than the owner reviews or merges, so `{{DEFAULT_BRANCH}}` changes only by merge. The mode in force is in `project/working-agreement.md`.

- `guard.sh` is installed with `ALLOW_DEFAULT_BRANCH_PUSH=0`: a push to or from `{{DEFAULT_BRANCH}}` asks the owner, and a force push, `--all`, `--mirror`, a hard reset and a forced clean are blocked.
- Work on short branches named `feat/...`, `fix/...`, `chore/...` or `docs/...`, cut from the latest `origin/{{DEFAULT_BRANCH}}`, one concern and one pull request per branch. Merge `origin/{{DEFAULT_BRANCH}}` into the branch when it has moved.
- Squash-merge one change per pull request, so the default branch gets one commit per unit of work. Use a merge commit when the branch's own history matters to others. Where a merge queue is on, its method wins. Stacked changes use the host's stack tool.
- Before a pull request, `sh scripts/check.sh` passes. The body says what changed, why and how it was checked. End it with `Closes #N` only when the pull request finishes the issue; otherwise write "#N stays open until ..." without the words closes or fixes.
- Merge modes:
  - **orchestrator:** Claude squash-merges once the checks pass and the review is clean.
  - **human-review:** a named person approves. An agent review never counts, and Claude merges after that approval once branch protection is green.
  - **issues-only:** a partner owns the code. Claude opens no pull request and writes issues that say what and why.
- Merge and deploy are separate decisions. A merged change is not live until the owner has it deployed.
- Review fixes go to the same branch, because a second change for the same issue splits the review. Never push to a contributor's branch or edit their pull request: review it with comments and put a fix on a branch of ours.
- Read CI once with `gh pr checks`, then once more after a single wait of about the job's length, because polling loops burn the host's rate limit. After every merge, read the default branch's own run, because a red default branch nobody looks at stays red.
- One red test in a file the branch did not touch gets one rerun. A failure that reproduces is a regression; reproduce a CI-only failure in the smallest local run before changing code.
- Commit by path: name the files in `git add src/a.txt`, then `git commit`. Never `git commit -a` or `-am`, because a sweep picks up files another session left in the tree. `guard.sh` blocks both.
- The subject is imperative, about 50 characters, with no full stop. Add a type prefix such as `fix:` only when release tooling reads it, and follow the repo's own convention when it has one.
- Run git as `git -C /absolute/dir status` and write long messages to a file, because `cd dir && git ...` shapes trigger approval prompts.
- On any HTTP 403 or 429, "secondary rate limit" or "abuse detection" from git or the host's CLI, stop all git and host work and show the owner the exact error. A retry can turn a warning into a suspension.
- On GitLab read `gh` as `glab` and pull request as merge request.
