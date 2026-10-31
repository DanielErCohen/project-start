# Working agreement

How {{PROJECT_NAME}} is run. Terms: [GLOSSARY.md](GLOSSARY.md).

## Decision rights

| Area | Decider | Note |
|---|---|---|
| Product scope, brand, voice | {{OWNER}} | |
| Spend: a new paid service, a model escalation, anything that raises monthly cost | {{OWNER}} | Ceiling: [plan.md](plan.md) |
| Go-live | {{OWNER}} | |
| Anything that reaches other people | {{OWNER}} | Drafts are fine |
| Irreversible actions: deleting data, publishing | {{OWNER}} | Holds in every mode |
| {{OWNER}}'s own accounts and dashboards | {{OWNER}} | |
| Technical choices | Claude | Costly ones go in [decisions.md](decisions.md); cost or provider changes are {{OWNER}}'s |
| Settings and permissions | {{OWNER}} | Claude suggests rules in its report |
| Permission mode (auto mode or approval prompts) and sandbox | {{OWNER}} | Now: <auto mode or approval prompts, sandbox on or off> |

> ADAPT: put a name in the Decider column wherever someone other than {{OWNER}} decides, then delete these examples. Rows to copy:
>
> | Area | Decider | Note |
> |---|---|---|
> | Pricing, customer promises | <name>, sales cofounder | |
> | Budget above <amount per month> | <name>, VP | |
> | Contracts, product claims | <name>, legal | |
> | Look and feel, copy | <name>, designer | |

**Tie-break.** When two deciders conflict, the status quo stands, both go in [owner.md](owner.md) and work carries on elsewhere. The arbiter is {{OWNER}}. After 7 days without an answer, the item's default applies and is logged in [decisions.md](decisions.md).

## Mode

`{{MERGE_MODE}}` is in force, and sets who accepts finished work:

- **solo:** {{OWNER}} is the only person involved. Finished work lands directly once the checks pass.
- **orchestrator:** Claude accepts the work once the checks pass and the review is clean.
- **human-review:** a named person accepts each change. An agent review never counts.
- **issues-only:** a partner owns the work. Nobody here accepts anything; the output is issues that say what and why.

A grant of authority is written here with scope and date, because a chat grant is lost with the session: <who, date, scope>.

## Models (list prices per million tokens as of Oct 2026, re-read when a model ships)

| Job | Model | Effort | Input / output |
|---|---|---|---|
| Planning and orchestration | Opus 5.5 | medium, high for hard work | $4 / $20 |
| Coding, and parallel or routine work | Sonnet 5.5 | medium | $2 / $10 |
| Review, in a fresh context | Sonnet 5.5 | high | $2 / $10 |
| Recon and checkable subtasks | Haiku 5.5 | medium | $0.10 / $0.50 |
| Escalation: an owner ask, logged in [decisions.md](decisions.md) | Fable 5.1, when Opus at high effort falls short | high | $10 / $50 |

- Set `model` and `effort` in every agent definition.
- A prompt for Opus carries no "verify" line, because it over-verifies. A prompt for Sonnet or Haiku carries one line requiring the real check to run, because they sometimes report done without it.
- The Haiku price holds for prompts up to 100,000 tokens.

## How one piece of work flows

1. **Start.** Read [owner.md](owner.md), [plan.md](plan.md) and [decisions.md](decisions.md).
2. **Frame.** A small fix starts as the problem, the expected behavior and one check that proves it. Write a spec only when an interface, stored data or money changes. Use plan mode when the change takes more than a sentence to describe.
3. **Work.** One session plans and does the work. Subagents take read-only recon and independent slices, so no two writers share a file.
4. **Check.** Run the checks and read the real output.
5. **Review.** One review in a fresh context or by a person who did not write the change, after the checks pass. A second round only re-checks a fix; stop at two. Payments, sign-in, personal data and stored data also get a security review and a review by a different model family or a domain expert.
6. **Accept.** Per the mode.
7. **Go live.** A separate decision from step 6, because accepted work is not live until it is deployed. {{OWNER}} decides; check the result.
8. **Close.** Update the three session files; write the handoff note.
