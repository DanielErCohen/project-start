# Delegated builds

Single-agent coding is the default. Delegate only an independent slice: no shared file, no shared stored data, a brief that fits one page. Parallel agents make conflicting implicit decisions.

## Subagents

- Use `builder`; `isolation: worktree` gives each its own checkout.
- The brief names the base commit, the files the slice owns, the acceptance commands and every must-hold rule, since a worktree agent may not load this repo's rules.
- Done means the commit exists, the orchestrator's rerun of the gate passes, and the diff stays inside the slice.
- The caps in `.claude/settings.json` bound concurrency; raise them after a clean batch, since a loaded machine produces failures that look like defects.
- Only the orchestrator pushes. The agent's instructions forbid a push, and its definition lists no command patterns, since a reworded command slips past one.

## Other vendors' tools

Claude Code hooks and settings do not bind another vendor's CLI, so setup is the only enforcement:

- Strip credentials from the worktree before the tool starts, where `WT` is the worktree path. Run `git -C "$WT" config extensions.worktreeConfig true`, then `git -C "$WT" config --worktree credential.helper ''`. The `--worktree` form matters: a plain `config` writes the `.git/config` that every worktree shares and strips the orchestrator's own helper. Launch the tool with no token variable in its environment and with `GIT_SSH_COMMAND=false`, because an SSH key without a passphrase still pushes: `env -u GH_TOKEN -u GITHUB_TOKEN -u GITLAB_TOKEN -u SSH_AUTH_SOCK GIT_SSH_COMMAND=false <tool>`. A push then fails.
- Input from `/dev/null` and a deadline, because an open input hangs a run silently.
- No flag that skips permission prompts.
- Only the routine tasks listed in `AGENTS.md`.
- Rerun the gate on its commit before anything counts as done, since some tools exit 0 on a provider error.

The tool's own hooks never run here, so the commit and push limits in `AGENTS.md` are text. The credential stripping above is what enforces them.
