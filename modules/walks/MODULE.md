# Module: walks
Trigger: v1 has users besides the owner, and a person sees, calls or reads something this project builds.
Adds: `.claude/agents/qa-tester.md`, `.claude/skills/persona-test/SKILL.md`, `project/personas.md`.
## Append
- CLAUDE.md | Walks: brief qa-tester before a change a person sees or uses lands; run /persona-test for how a flow feels.
- project/working-agreement.md | A change a person sees or uses is walked on the real target before it merges (in solo mode, before it is pushed); a skipped walk needs a stated reason.
## Manual
- Add the tool that drives the target (browser or simulator) to `tools` in `qa-tester.md`.
- Fill the persona cards in `project/personas.md` from real feedback or dated research.
Skip when: the owner is the only user, or nothing here has a human-facing surface.
