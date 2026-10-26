# Module: shutdown
Trigger: a stop is decided. Install it then; the installer adds a module later without touching filled files.
Adds: `project/shutdown.md`.
## Append
- CLAUDE.md | The project is stopping or stopped (project/shutdown.md): change and restart nothing without the owner's ask.
- project/working-agreement.md | Stop, pause or retire: the owner.
- project/decisions.md | Stop decided: log the date, the reason and what would reverse it.
## Manual
- In `.claude/hooks/guard.sh` add the stack's stop, scale and delete commands to `PROD_PATTERNS`, with a test case.
Skip when: no stop is decided.
