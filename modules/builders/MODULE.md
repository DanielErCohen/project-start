# Module: builders
Trigger: the owner wants independent slices built in parallel, or another vendor's command-line tool to take routine tasks.
Adds: `.claude/agents/builder.md`, `.claude/rules/builders.md`, `AGENTS.md`.
## Append
- CLAUDE.md | Delegated builds follow .claude/rules/builders.md; AGENTS.md holds hard limits for other tools.
- project/working-agreement.md | Models: Builder subagent | Sonnet 5.5 | medium - independent slices and the routine tasks listed in AGENTS.md.
## Manual
- In `.claude/settings.json` add `"env": {"CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS": "3", "CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH": "1"}`.
- Keep the project's list of routine tasks in `AGENTS.md` to what the owner agrees.
Skip when: one session codes everything in turn, which is the default.
