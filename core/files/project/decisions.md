# Decisions

Three sections. The log is never rewritten: a changed decision becomes a new entry. Everything else in the project states the current state, with history in git.

## Log

*Costly-to-reverse decisions and stop lines, oldest first. One row each. A row carries its reason and the result that would reopen it.*

| Date | Decision | Why | What would change it |
|---|---|---|---|
| YYYY-MM-DD | <the decision, in one sentence> | <the reason> | <the result or event that reopens it> |

## Open questions

*Each question names the default in use, what it blocks and what settles it. Work carries on with the default. When {{OWNER}} answers, the answer moves to the file that owns the topic, a costly one also gets a log row, and the question leaves this list.*

- **<Title>.** Default in use: <the default>. Blocks: <what, or nothing>. Settles it: <who does what>. If {{OWNER}} chooses otherwise: <what changes>.

## Deferred

*Items that wait on purpose, one line each with the reason and the trigger that brings them back. Anything a person would see or use does not belong here; it is fixed in its own change.*

- **<Title>.** Waits because <reason>. Comes back when <trigger>.
