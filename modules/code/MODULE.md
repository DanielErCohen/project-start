# Module: code
Adds: `scripts/check.sh`, `.claude/rules/git.md` (from `git-solo.md` in solo mode, else `git-review.md`), `.claude/rules/testing.md`, `.claude/rules/comments.md`, `docs/README.md`.
## Append
- CLAUDE.md | Git: commits, branches and the merge modes are governed by `.claude/rules/git.md`.
- CLAUDE.md | Commands and layout: <install, typecheck, test, lint and build commands, the environment a test needs, and the top-level folders that exist, one line each>, then three to six rules that hold across the codebase, each with its reason. The local gate is `sh scripts/check.sh`.
- project/GLOSSARY.md | **Git terms:** a commit is one saved snapshot with a message; a branch is a named line of commits; a pull request asks to merge a branch, where review and checks run; the gate is the fixed list of checks a change passes first; a worktree is a second working copy so two agents never edit the same files.
- project/working-agreement.md | Work: a subagent that edits runs with `isolation: worktree`, because two writers in one working copy corrupt each other.
- project/working-agreement.md | Check: run `sh scripts/check.sh`. It stops at the first failure and fails when no step has a command.
- project/working-agreement.md | Merge: follows the mode in force; the rules for each mode are in `.claude/rules/git.md`.
- project/working-agreement.md | Deploy: the owner decides, separately from merge, because a merged change is not live until deployed. Check the result afterwards.
- project/working-agreement.md | Devices: a private remote makes the project reachable from a phone and a cloud session. Ask early, and create it private after one yes.
## Manual
- Fill the commands in `scripts/check.sh` for the stack. The gate fails until at least one step has a command.
- Add the stack's read-only commands (test, lint, typecheck, build) to the `allow` list in `.claude/settings.json`, so routine checks do not prompt.
- Set the `paths` in `.claude/rules/comments.md` and `testing.md` to the repo's source and test folders.
