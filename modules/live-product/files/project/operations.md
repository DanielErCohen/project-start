# Operations

What {{PROJECT_NAME}} promises, how it answers users, and how it checks the promises hold.

## Flow mode

The default queue is one ready item at a time: each cycle takes the top ready item, ships it, and idles when none is ready, because small steps show which change caused a problem. An item is ready when it has the problem and expected behaviour, one check that proves it, what is out of scope, and file and line notes from a read of the code.

## Commitments register

Every promise published to users (refund window, delivery time, deletion timing) maps to the code that keeps it or to a runbook with a named owner. A promise with no mapping is a defect: map it, or change the promise with {{OWNER}}'s yes. A promise resting on one inbox fails when its owner is away.

> ADAPT: list this product's real promises; delete the example.

| Promise | Published at | Kept by (code or runbook) | Owner | Last checked |
|---|---|---|---|---|
| Refund within N days | terms page | refund row of support triage | {{OWNER}} | |

## Support triage

Each inbound message is sorted into one kind. The agent prepares a draft and a note; {{OWNER}} sends every reply, because a sent message cannot be recalled.

- **Bug:** reproduce it, then file an issue.
- **Refund:** check the order at the payment processor, apply the promise above, and hand the draft to {{OWNER}}.
- **Question:** answer from the published pages.
- **Privacy request (access, export, deletion):** write down the receipt date, locate the data, and tell {{OWNER}} the same day, since legal clocks start at receipt.

## Monthly money reconciliation

The payment processor is the source of truth for money, since a "paid" status in the app does not prove the money arrived. Each month, pull charges, refunds, fees and payouts from the processor and the app and compare them line by line. The difference reads zero before any report or tax use, and each non-zero line is explained. State dates, currency and filter with the figures.

Sales with no order row usually cause a difference. Missing expenses stay on a chase list, since recorded expenses are a floor. The amount a customer sees equals the amount charged.

## Public claims register

Every public claim (interface text, legal pages, ads, support replies) is listed with its evidence and checked against the code. When they differ, {{OWNER}} chooses which changes, and the choice goes in `decisions.md`. Columns: claim, where, evidence, checked on.

## Conversion events after a release

The code does not show that an event fires. After each release, trigger every conversion event with a real action and see it on the live stream. Record event, trigger, date seen.

## Platform accounts

Applies to accounts on platforms that police automation: social networks, ad accounts, marketplaces, email providers.

- A captcha, "are you human" checkpoint, verification request or suspension notice stops all automation on that platform at once, because solving it or retrying turns a warning into a ban.
- Do not solve or bypass it. Tell {{OWNER}} what appeared and where; {{OWNER}} clears it in their own session.
- After it is cleared, wait out a cooldown (default 48 hours, recorded in `project/owner.md`) before automation resumes.
- Run bulk actions in their own sessions, so a stop in one leaves routine work running.

## Production probe log

One line per read, written before the query runs: date, question, granted by, time limit, query, result (rules in `.claude/rules/production-access.md`).
