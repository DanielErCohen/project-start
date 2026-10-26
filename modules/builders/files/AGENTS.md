# Contract for agents working in this repo

Applies to every subagent, parallel worker and other vendor's tool. Other tools do not load `.claude/rules/`, so paste what a task needs into their brief.

## Hard limits

- Work only in your worktree; a second writer in one tree corrupts both runs.
- No `git push`, `gh`, `glab` or host API calls. Commit locally with `git add <path>`; `git commit -a` is out. The orchestrator pushes, so one session owns the host's rate limit.
- On HTTP 403, 429 or "secondary rate limit": stop all git and host work and report the exact error.
- Never read, write or print env files or secrets, and never connect to production.
- Tests use fixtures. No destructive commands outside your worktree, and no flag that skips permission prompts.
- Change `.claude/settings*.json` only on the owner's word, since a permission rule widens what every later session may do. List a useful rule in your report.

## How to work

- Keep working until everything asked is done; stop only when blocked or before a risky step. Add nothing unasked.
- Diff against the base commit in your brief; a local `{{DEFAULT_BRANCH}}` can lag.
- Run the acceptance commands and report their real output. Report a missing tool and stop.
- List anything out of scope as OPEN.

## Routine tasks other tools may take

- Formatting with the project's formatter.
- Lint fixes that change no behaviour.
- Typos in documentation and comments.

Not routine: dependency bumps, renames, and anything that changes what ships. Those go to a `builder` subagent with a brief, or stay with the orchestrator.
