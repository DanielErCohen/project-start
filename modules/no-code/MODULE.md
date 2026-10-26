# Module: no-code
Trigger: the project produces documents, content or services without code, or runs a recurring cycle in place of builds.
Adds: `project/deliverables.md`, `project/operations.md`.
## Append
- CLAUDE.md | Recurring work: project/operations.md replaces sprints; outputs are filed in project/deliverables.md.
- project/plan.md | Next cycle: the weekly checklist in project/operations.md.
- project/working-agreement.md | Send anything to a client or audience: the owner approves each draft, and a client who must approve each item does so before it goes out. This is the merge-mode equivalent.
## Manual
- If the owner wants the weekly cycle run on a schedule, create a routine with `/schedule` that drafts it and files the drafts; it sends nothing.
- If `live-product` also installs, both add `project/operations.md`: keep one file, this cycle first, then the live-product sections.
Skip when: the project builds software in batches or flow.
