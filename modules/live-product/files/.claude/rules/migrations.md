---
paths:
  - "**/migrations/**"
  - "**/*.sql"
---

# Migrations

> ADAPT: set `paths` to this stack's migration folder and schema files.

Old and new code run side by side during a deploy, and migrations often apply on merge, before the code does.

- Every migration works with the code live in production now and with the code in the pull request. Reason: the schema changes first and the old code still serves users.
- Additive changes (a new nullable column or table) may ship with the code that uses them.
- Drops, renames and new NOT NULL constraints take three steps, each its own deploy: expand (add the new structure, write to both), migrate (backfill, switch reads), contract (remove the old structure). When step 1 merges, add the contract step to `project/plan.md` with a date. Reason: the contract step gets skipped and the old structure stays for years.
- Merge one schema change at a time, and wait for any deploy in progress to finish. Reason: with two changes in flight a failure cannot be attributed.
- Never edit a migration that exists on the default branch; fix it with a new one, since the old one has already run elsewhere. A migration added on your own branch has run nowhere and stays editable until it merges.
- After the deploy, read row counts and the error rate for what changed, and probe a route or query the merge added to confirm what is live.
