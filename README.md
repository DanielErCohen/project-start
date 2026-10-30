# project-start

A starter that an agent installs into a new or existing project after it interviews and challenges you. It supplies what Claude Code lacks: the project's facts, who decides what, what waits on you, checks, guards and rules, each traced to a failure in [LEARNINGS.md](LEARNINGS.md).

Distilled from building a live consumer app, a B2B tool I later stopped and a mobile app in progress, with Claude doing the build.

## Start

**In Claude Code.** Clone this repo outside your project, open Claude Code in your project folder and paste:

```text
Start a project from <path>/project-start/START.md
```

Needs git 2.28 or later, and Git Bash on Windows. On an existing repo the installer never overwrites: it writes `<file>.project-start` beside yours to merge. START.md is for Claude Code only.

**In the Claude app, no terminal.** Paste this into a new chat. It interviews and challenges you, then returns `brief.md`, `owner.md` and, for personal data, a privacy block. Keep them in a Claude Project's files or a notes or docs app; the Claude Code path installs the rest later.

```text
Interview me for a new project, one question at a time, each with a default I accept by saying "ok": 1 name and one line; 2 who it is for, and when one of them last paid, switched or complained; 3 smallest useful version; 4 what result by what date would make me stop; 5 hours per week and monthly spend ceiling, as numbers; 6 code or no code, and the stack I know; 7 where people reach it; 8 personal data, including other people's data I paste into chats; 9 who else decides; 10 the three things that must never go wrong; 11 my devices and sessions; 12 where the repo lives.
Skip what my notes answer. Challenge only on a red flag: your assessment, the strongest counter, one recommendation. When the remaining defaults are good enough, stop and list them.
Never take a bare "ok" on question 8: ask what data, whose, and which tool may see it. If the project is for an employer or a client, ask me to check their rules on AI tools first.
Then return markdown blocks. brief.md: what it is, who it is for, what it does not do, each belief with an "it is wrong if" line, kill lines with a number, a read date and a decision per outcome (one review date for a learning project). owner.md: each item waiting on me as a plain title expanded into every step with a default, and where each account and secret lives. When personal data is in scope, a privacy block: the data, whose it is, which tools may see it, what is never pasted.
```

**By hand.** Answer the twelve fields in [QUESTIONS.md](QUESTIONS.md), pick modules from its trigger table.

From the project-start folder:

```text
sh tools/install.sh --target ~/my-project --mode solo --code --modules privacy
sh tools/verify.sh --target ~/my-project
```

`--mode` is `solo` (default), `orchestrator`, `human-review` or `issues-only`. Fill every `{{TOKEN}}` and `> ADAPT:` passage.

## What you get

- `CLAUDE.md` under 60 lines, and a `project/` folder: brief, plan, decisions, owner list, working agreement (decision rights, merge mode, models) and glossary.
- Permissions in `.claude/settings.json`, and one tested guard hook against force pushes, destructive resets and env-file edits.
- With `--code`: a local check script, testing, comment and git rules for your mode, and an engineering-docs rule.
- [PRINCIPLES.md](PRINCIPLES.md) holds the reasoning and sources; [LEARNINGS.md](LEARNINGS.md) maps each failure to the file that holds its rule.

## Modules

Installed only when your answers call for them, per the trigger table in [QUESTIONS.md](QUESTIONS.md): `code`, `sprints` (batched work), `review`, `walks` (a real-target tester), `ui`, `ai-feature`, `builders` (parallel agents), `open-source`, `team`, `live-product`, `privacy`, `no-code`, `experiments`, `shutdown`.

## Limits

- Hooks and permissions enforce only in Claude Code. The app path yields documents and no enforcement.
- Model names and Claude Code features are dated October 2026; the agent checks them first.
- The installer copies files: no network, no remote, no account.

## License

MIT, see [LICENSE](LICENSE).
