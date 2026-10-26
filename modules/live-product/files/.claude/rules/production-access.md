# Production access

An agent session may read production and may not write to it. A change reaches production through a reviewed merge and a deploy that {{OWNER}} approves.

A read is allowed when all of these hold:
- **Read-only at the role:** the session uses a database role that cannot write, set up in the database and not in the client. Reason: an over-privileged token has let an agent delete a production database in seconds.
- **A named question,** written in the probe log of `project/operations.md` before the query runs, with {{OWNER}}'s yes.
- **A time limit,** default 30 minutes; the credentials are removed after it.
- **Logged:** date, question, query, result.
- **Personal fields excluded:** select counts, ids, statuses and timestamps. Leave out names, emails, free text and payment data. Reason: a result pasted into a session reaches a model vendor.

If a probe shows a live defect, write the issue and stop. A data fix goes through review as a migration or script.
