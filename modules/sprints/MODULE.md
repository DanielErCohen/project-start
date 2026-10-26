# Module: sprints
Adds: `.claude/skills/sprint/SKILL.md`, `project/sprints/_template.md`, `project/sprints/_handoff.md`.
## Append
- CLAUDE.md | Sprints: run the sprint skill at session start and close; sprint files live in project/sprints/.
- project/plan.md | Current sprint: the newest file in project/sprints/ holds its status table and handoff.
- project/working-agreement.md | Session start also reads the newest sprint status table and handoff.
## Manual
- Check that the sprint skill's build step matches the installed merge mode: in solo mode pieces are committed in order on the default branch, with no branches.
