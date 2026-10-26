# Team and decision rights

> ADAPT: replace every `<name>` with a person or role, and keep or delete the example rows. Each area has one decider and one arbiter; two deciders for one area is a fault to fix at install.

| Area | Decider | Arbiter |
|---|---|---|
| Product scope, brand, voice | <name> | <name> |
| Spend (new paid service, plan change, over the ceiling) | <name> | <name> |
| Go-live, release, anything reaching customers or the public | <name> | <name> |
| Data and legal | <name> | <name> |
| Security | <name> | <name> |
| Technical choices | <name> | <name> |
| Merge approval | <name> | <name> |
| Deploy (separate from merge, since a merge can apply migrations before code goes live) | <name> | <name> |
| Settings and permissions | <name> | <name> |

> ADAPT: example rows to add when they apply: pricing and anything that changes a customer's charge (the sales cofounder); sign-off to go live (the VP); contract and data questions (legal); screens and copy (the designer). Name who approves code when the product owner does not.

## Rules

- **Tie-break:** when two people disagree, the status quo holds until the arbiter answers. If the arbiter has not answered 7 days after the question reaches them, the default stated with the question applies and is logged in `decisions.md`.
- **Merge mode** is `human-review` or `issues-only`. In `human-review` the person named in the Merge approval row approves every change and an agent review never counts as that approval. In `issues-only` a partner owns the code, nobody here merges, and the output is issues.
- **Conflicting instructions:** the agent acts on neither, lists both in `project/owner.md` with the decider from the table, and works on something else.
- **Technical choices:** the decider in that row chooses. When the row names Claude, Claude chooses and records costly ones in `decisions.md`.
- **A grant is written down** here with scope and date ("<name> authorised the agent on <date> to <action>, except <limit>"), because a grant given in chat is lost with the session.
- **Handoff and owner file:** handoff notes go in the pull request body, and `project/owner.md` changes only on the default branch, because every branch that edits those lines conflicts with the others.

## Issues-only

Check every raw item (finding, request, feedback row) against the code before filing it, whoever wrote it. An issue is ready only when every field of `.github/ISSUE_TEMPLATE/ready-issue.md` exists. On GitLab keep the template in `.gitlab/issue_templates/`.
