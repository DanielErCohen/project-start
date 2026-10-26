# Module: privacy
Adds: `project/privacy.md`, `project/incident.md`.
## Append
- CLAUDE.md | Personal data: read project/privacy.md before handling real user or client data; incidents follow project/incident.md.
- project/owner.md | Privacy open items: the unchecked boxes of project/privacy.md, each with a default.
- project/decisions.md | Data position: log what may enter model sessions (default none, ask) and the date.
## Manual
- When the product sends telemetry, add the scrub test from `privacy.md` as a step in `scripts/check.sh`; otherwise delete the Telemetry section.
- Add the client or user folder to `Read` deny rules in `.claude/settings.json` if it sits outside `private/`.
