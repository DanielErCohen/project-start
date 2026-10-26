# Learnings

Failures that produced a rule, and the installed file that holds each rule. A rule with no installed home has no row. A project adds a row after its own failure and gives the lesson one home.

| Failure | Rule | Where it lives |
|---|---|---|
| The owner's list filled with engineering decisions. | Only items blocked on the owner go on the list. | core/files/project/owner.md |
| The owner returned to ask for the steps behind an item. | Each item expands to every step, the exact path, what to write back, and a default. | core/files/project/owner.md |
| Technical questions were put to the owner. | Claude decides technical points and records the costly ones in `decisions.md`; the owner decides scope, spend, go-live, other people and irreversible actions. | core/files/project/working-agreement.md |
| An agent review was counted as the human approval. | In human-review mode an agent review never counts. | core/files/project/working-agreement.md |
| A merge was read as permission to deploy. | Accepting work and going live are separate decisions. | core/files/project/working-agreement.md |
| A handoff held claims already out of date. | The next start compares the handoff's commit with the git log, and a mismatch is explained first. | modules/sprints/files/.claude/skills/sprint/SKILL.md |
| Decided items were raised again. | `decisions.md` is a dated log that is never rewritten; a changed line adds an entry. | core/files/project/decisions.md |
| A bar moved after the result came in. | Kill lines are written before the test, from the user's need, never from a past best score. | core/files/project/brief.md |
| Every roadmap item looked equally certain. | Each item is graded validated, bet or assumption. | core/files/project/plan.md |
| A failed kill line was followed by a new metric. | A failed line triggers a decision to stop, pivot or rescope. | modules/experiments/files/project/experiments.md |
| A kill test was scheduled with data that could not be joined. | The data check comes before the test; "not measured" never passes. | modules/experiments/files/project/experiments.md |
| "Shipped" was reported as "adopted". | Claims carry a stage: proposed, delivered, reported, measured, verified. | core/files/CLAUDE.md |
| A rule in `CLAUDE.md` was skipped. | A rule that must hold every time is a hook or a permission rule. | core/files/CLAUDE.md, core/files/.claude/settings.json, core/files/.claude/hooks/guard.sh |
| Instruction files grew and adherence fell. | `CLAUDE.md` stays under 60 lines; procedures live in skills. | core/files/CLAUDE.md |
| Carried-over "verify carefully" lines caused over-verification on the top model. | Prompts for the top model carry no verify lines; prompts for smaller models carry one line requiring the real check to run. | core/files/project/working-agreement.md |
| The wrong model was chosen again and again. | Models are one dated table with effort per role. | core/files/project/working-agreement.md |
| Subagents edited one tree and collided. | An editing subagent runs with worktree isolation. | modules/builders/files/.claude/rules/builders.md |
| A blanket commit swept in another agent's half-finished edit. | Commit by path; the guard blocks `commit -a`. | core/files/.claude/hooks/guard.sh |
| An agent read a secrets file through the shell. | Bash reads and edits of env files are blocked, and Read is denied. | core/files/.claude/hooks/guard.sh, core/files/.claude/settings.json |
| A hook blocked a harmless `echo`, and failed open on input it could not parse. | Every blocking hook has false-positive tests and fails closed. | core/files/.claude/hooks/guard.test.sh |
| The project's own deploy and migration commands slipped past the guard. | The stack's production commands are added to the guard's list at install. | core/files/.claude/hooks/guard.sh |
| A gate step named a tool the project did not have. | An empty command is skipped and reported as SKIP. | modules/code/files/scripts/check.sh |
| A bug fix shipped with no proof of the bug. | A fix starts with a test that fails before the fix. | modules/code/files/.claude/rules/testing.md |
| Tests passed after the behaviour broke. | Tests assert observable behaviour, and an assertion is never weakened to pass. | modules/code/files/.claude/rules/testing.md |
| A branch cut before a fix merged failed on the bug the fix cured. | Merge the default branch into the branch when it has moved. | modules/code/files/.claude/rules/git-review.md |
| An account was suspended after heavy automated git traffic. | On HTTP 403 or 429 stop all git and host work and show the owner the error. | modules/code/files/.claude/rules/git-solo.md, modules/code/files/.claude/rules/git-review.md |
| Code-repo documents carried status and rotted. | `docs/` holds engineering documents that name the code they cover. | modules/code/files/docs/README.md |
| The same reviewer context found only what the author had seen. | Review runs in a fresh context after the checks pass. | modules/review/files/REVIEW.md |
| Review rounds on minor points delayed every merge. | One review round, a second only to re-check a fix, stop at two. | modules/review/files/REVIEW.md |
| A high-risk change was reviewed once by the same model family. | Risk classes add a security review and a different family or a human. | modules/review/files/REVIEW.md |
| A tester's FAIL contradicted the spec and cost a revert. | Check each FAIL against the spec and the by-design list before routing it. | modules/walks/files/.claude/agents/qa-tester.md |
| A browser check passed what a phone screen got wrong. | Walk the real target before merge. | modules/walks/files/.claude/agents/qa-tester.md, modules/walks/MODULE.md |
| Persona sessions judged the implementation. | Personas are code-blind, and the synthesis drops findings that cite code. | modules/walks/files/.claude/skills/persona-test/SKILL.md |
| Correct code made the user work: dead ends, lost drafts, missing controls. | Making the user work is a defect, with checks in the rule. | modules/ui/files/.claude/rules/usability.md |
| Tests called a live model provider. | Tests use fixtures. | modules/ai-feature/files/.claude/rules/ai.md |
| A model-produced number or safety text was unverifiable. | Code computes every number and rule; the model words them; output is validated. | modules/ai-feature/files/.claude/rules/ai.md |
| A pipeline reported success with nothing produced. | Empty, failed and degraded are three results, and each pipeline checks its output count. | modules/ai-feature/files/.claude/rules/ai.md |
| A changed judge or formula broke comparison with earlier rounds. | The judge, rubric and formula are pinned with a version. | modules/ai-feature/files/.claude/rules/ai.md |
| Another vendor's builder pushed with no hook in the way. | Builders get a worktree, no push credentials, and the gate is rerun on their result. | modules/builders/files/.claude/rules/builders.md |
| A tool exited 0 on a provider error. | Done means the commit exists and the acceptance command passes on rerun. | modules/builders/files/.claude/rules/builders.md |
| A migration that applied on merge broke the live code. | Every migration works with the code now in production. | modules/live-product/files/.claude/rules/migrations.md |
| The contract step of a schema change was never done. | The contract step goes on the plan with a date when the first step merges. | modules/live-product/files/.claude/rules/migrations.md |
| Two migrations in flight made a failure impossible to attribute. | Merge one schema change at a time. | modules/live-product/files/.claude/rules/migrations.md |
| A deploy was assumed live. | A post-deploy check probes a value the release added. | modules/live-product/files/project/release.md |
| A switch that fails closed was never configured and dropped everything silently. | Each fail-closed switch is verified in production. | modules/live-product/files/project/release.md |
| The app's order table disagreed with the payment processor. | The processor is the source of truth; the monthly difference reads zero. | modules/live-product/files/project/operations.md |
| A published promise rested on one inbox. | Each promise maps to code or a runbook with an owner. | modules/live-product/files/project/operations.md |
| Interface copy promised a behaviour the code lacked. | Public claims are listed and checked against the code. | modules/live-product/files/project/operations.md |
| A conversion event fired on the wrong trigger and nobody saw. | After each release, trigger every event and see it on the live stream. | modules/live-product/files/project/operations.md |
| A drafted reply was sent before anyone read it. | Support drafts are never sent by the agent. | modules/live-product/files/project/operations.md |
| An over-privileged token deleted production data. | Production reads are read-only at the role, with a named question, a time limit and a log. | modules/live-product/files/.claude/rules/production-access.md |
| An automated action answered a platform challenge and the account was suspended. | A captcha, checkpoint or suspension stops automation until the owner clears it. | modules/live-product/files/project/operations.md |
| Real people's data went into a session with no data position. | The data position is written first. | modules/privacy/files/project/privacy.md |
| Telemetry carried personal values past a denylist. | Scrub by allowlist and test against the production build. | modules/privacy/files/project/privacy.md |
| Client files were committed. | They stay in a git-ignored `private/` folder. | modules/privacy/files/project/privacy.md |
| A breach was handled with no record and no clock. | Stamp the time of awareness; one record per event, including those with no notice. | modules/privacy/files/project/incident.md |
| A scale-to-zero command did not hold, and a bucket stayed live unbacked. | A stop command that holds, a recheck after a delay, and a list of what is not backed up. | modules/shutdown/files/project/shutdown.md |
| A stopped project was restarted by accident. | The freeze rule: nothing restarts without the owner's ask. | modules/shutdown/files/project/shutdown.md |
