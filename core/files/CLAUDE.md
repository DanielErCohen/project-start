# {{PROJECT_NAME}}

> ADAPT: replace this line with what the project is, in two sentences: the thing, who it serves and the change it makes for them. Then delete this line.

{{OWNER}} owns the project and directs the Claude Code sessions that do the work. This file is the map and the few rules that hold everywhere. Procedures live in skills and the details in the files below, so this file stays under 60 lines and is followed.

## Where truth lives

- `project/brief.md`: what the project is, who it is for, what it does not do, the beliefs it rests on. Where another file disagrees, the brief wins.
- `project/plan.md`: what is now, next and later, each item graded and with a done-when, plus the handoff note from the last session and the monthly spend.
- `project/decisions.md`: the log of costly decisions, the open questions with their defaults, the deferred items.
- `project/owner.md`: only what is blocked on {{OWNER}}, and where each account and secret lives.
- `project/working-agreement.md`: decision rights, the mode, the models table, how one piece of work flows.
- `project/GLOSSARY.md`: the project's terms in one plain line each.

## Session start and close

- Start: read `project/owner.md` and apply any answers {{OWNER}} left, read `project/plan.md` and resume from its handoff note, read `project/decisions.md` so a settled choice is not reopened. A session remembers nothing else.
- Close: update those three files so they state the current state, refresh `project/owner.md` to what is still blocked, and write the handoff note at the top of `project/plan.md`: what is done, what is next, what waits on {{OWNER}} with its default.

## Rules that hold everywhere

- IMPORTANT: before anything that spends money, reaches other people or cannot be undone, find the area in the decision table in `project/working-agreement.md` and stop and ask the decider it names. A wrong guess in these areas costs more than the wait.
- Technical choices are yours. Make them, state the reason in one line and record the costly-to-reverse ones in `project/decisions.md`, because a technical question put to {{OWNER}} stalls work you could settle.
- Ask one question at a time, with a default and what changes with each answer. Work continues on the default, so no question blocks the project.
- Write plain words, bottom line first. Never write an internal code or label; say what the thing is in a sentence, because {{OWNER}} has not seen your labels.
- A claim carries its stage (proposed, delivered, reported, measured, verified), a unit, a date and its basis. "Not measured" is never a pass.
- Files state the current state and the version history holds the past, except the decision log, which is never rewritten.
- A block from `.claude/hooks/guard.sh` or a permission prompt is a rule doing its job. Report it, and change a rule only on {{OWNER}}'s word, because a loosened rule applies to every later session.
- Real env files and secrets are never read, written or printed. `.env.example` is the shape; {{OWNER}} sets the values.
- A lesson becomes a rule in this file, in `.claude/rules/`, or a case in `.claude/hooks/guard.test.sh`; a rule that must hold every time becomes a hook or a permission rule, because this file is context a session may skip. Auto memory stays on one machine, so a lesson kept only there never reaches a phone, a cloud session or a teammate.

## Working agreement

Decision rights, the mode, the models table and the flow of one piece of work are in `project/working-agreement.md`. Read it before the first change.
