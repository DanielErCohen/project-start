# Module: team
Trigger: more than one person decides (partner, sponsor, client), or a partner developer owns the code.
Adds: `project/team.md`, `project/stakeholders.md`, `.github/ISSUE_TEMPLATE/ready-issue.md`, `.claude/skills/stakeholder-review/SKILL.md`.
## Append
- project/working-agreement.md | Decision rights: project/team.md names each area's decider and arbiter and wins over the table above.
- project/working-agreement.md | Human-review merge rule, replacing the review module's: the approver in project/team.md approves each change, an agent review never counts, Claude merges after approval.
- CLAUDE.md | The stop-and-ask rule goes to the area's decider in project/team.md. In issues-only mode file work with the ready-issue template.
- project/plan.md | With several people on branches, handoff notes go in the pull request body.
- project/owner.md | Change this file only on the default branch; list conflicting instructions here with their decider.
## Manual
- Install with `--mode human-review`, or `issues-only` when a partner owns the code.
Skip when: one owner decides everything.
