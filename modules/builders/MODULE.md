# Module: builders
Adds: `.claude/agents/builder.md`, `.claude/rules/builders.md`, `AGENTS.md`.
## Append
- CLAUDE.md | Delegated builds follow .claude/rules/builders.md; AGENTS.md holds hard limits for other tools.
## Manual
- In `.claude/settings.json` add `"env": {"CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS": "3", "CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH": "1"}`.
- Keep the project's list of routine tasks in `AGENTS.md` to what the owner agrees.
