# Learnings

Failures that produced a rule, and the installed file that holds each rule. A rule with no installed home has no row. A project adds a row after its own failure and gives the lesson one home.

| Failure | Where it lives |
|---|---|
| The owner's list filled with engineering decisions. | core/files/project/owner.md |
| The owner returned to ask for the steps behind an item. | core/files/project/owner.md |
| Technical questions were put to the owner. | core/files/project/working-agreement.md |
| An agent review was counted as the human approval. | core/files/project/working-agreement.md |
| A merge was read as permission to deploy. | core/files/project/working-agreement.md |
| A handoff held claims already out of date. | modules/sprints/files/.claude/skills/sprint/SKILL.md |
| Decided items were raised again. | core/files/project/decisions.md |
| A bar moved after the result came in. | core/files/project/brief.md |
| Every roadmap item looked equally certain. | core/files/project/plan.md |
| A failed kill line was followed by a new metric. | modules/experiments/files/project/experiments.md |
| A kill test was scheduled with data that could not be joined. | modules/experiments/files/project/experiments.md |
| "Shipped" was reported as "adopted". | core/files/CLAUDE.md |
| A rule in `CLAUDE.md` was skipped. | core/files/CLAUDE.md, core/files/.claude/settings.json, core/files/.claude/hooks/guard.sh |
| Instruction files grew and adherence fell. | core/files/CLAUDE.md |
| Carried-over "verify carefully" lines caused over-verification on the top model. | core/files/project/working-agreement.md |
| The wrong model was chosen again and again. | core/files/project/working-agreement.md |
| Subagents edited one tree and collided. | modules/builders/files/.claude/rules/builders.md |
| A blanket commit swept in another agent's half-finished edit. | core/files/.claude/hooks/guard.sh |
| An agent read a secrets file through the shell. | core/files/.claude/hooks/guard.sh, core/files/.claude/settings.json |
| A hook blocked a harmless `echo`, and failed open on input it could not parse. | core/files/.claude/hooks/guard.test.sh, core/files/.claude/settings.json |
| The project's own deploy and migration commands slipped past the guard. | core/files/.claude/hooks/guard.sh |
| A gate step named a tool the project did not have. | modules/code/files/scripts/check.sh |
| A branch cut before a fix merged failed on the bug the fix cured. | modules/code/files/.claude/rules/git-review.md |
| An account was suspended after heavy automated git traffic. | modules/code/files/.claude/rules/git-solo.md, modules/code/files/.claude/rules/git-review.md |
| Code-repo documents carried status and rotted. | modules/code/files/docs/README.md |
| The same reviewer context found only what the author had seen. | modules/review/files/REVIEW.md |
| Review rounds on minor points delayed every merge. | modules/review/files/REVIEW.md |
| A high-risk change was reviewed once by the same model family. | modules/review/files/REVIEW.md |
| A tester's FAIL contradicted the spec and cost a revert. | modules/walks/files/.claude/agents/qa-tester.md |
| A browser check passed what a phone screen got wrong. | modules/walks/files/.claude/agents/qa-tester.md |
| Persona sessions judged the implementation. | modules/walks/files/.claude/skills/persona-test/SKILL.md |
| Correct code made the user work: dead ends, lost drafts, missing controls. | modules/ui/files/.claude/rules/usability.md |
| A model-produced number or safety text was unverifiable. | modules/ai-feature/files/.claude/rules/ai.md |
| A pipeline reported success with nothing produced. | modules/ai-feature/files/.claude/rules/ai.md |
| A changed judge or formula broke comparison with earlier rounds. | modules/ai-feature/files/.claude/rules/ai.md |
| Another vendor's builder pushed with no hook in the way. | modules/builders/files/.claude/rules/builders.md |
| A tool exited 0 on a provider error. | modules/builders/files/.claude/rules/builders.md |
| The contract step of a schema change was never done. | modules/live-product/files/.claude/rules/migrations.md |
| A deploy was assumed live. | modules/live-product/files/project/release.md |
| A switch that fails closed was never configured and dropped everything silently. | modules/live-product/files/project/release.md |
| The app's order table disagreed with the payment processor. | modules/live-product/files/project/operations.md |
| A published promise rested on one inbox. | modules/live-product/files/project/operations.md |
| Interface copy promised a behaviour the code lacked. | modules/live-product/files/project/operations.md |
| A conversion event fired on the wrong trigger and nobody saw. | modules/live-product/files/project/operations.md |
| A drafted reply was sent before anyone read it. | modules/live-product/files/project/operations.md |
| An over-privileged token deleted production data. | modules/live-product/files/.claude/rules/production-access.md |
| An automated action answered a platform challenge and the account was suspended. | modules/live-product/files/project/operations.md |
| Real people's data went into a session with no data position. | modules/privacy/files/project/privacy.md |
| Telemetry carried personal values past a denylist. | modules/privacy/files/project/privacy.md |
| Client files were committed. | modules/privacy/files/project/privacy.md |
| A breach was handled with no record and no clock. | modules/privacy/files/project/incident.md |
| A scale-to-zero command did not hold, and a bucket stayed live unbacked. | modules/shutdown/files/project/shutdown.md |
| A stopped project was restarted by accident. | modules/shutdown/files/project/shutdown.md |
