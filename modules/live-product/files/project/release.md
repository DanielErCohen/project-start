# Release checklist

{{OWNER}} approves the deploy, separately from the merge. The log records who approved. A field with no real value yet stays blank, because a placeholder reads as a value.

## Before

- [ ] The local gate passes and the review is done as `working-agreement.md` says.
- [ ] Each migration follows `.claude/rules/migrations.md`.
- [ ] A replaced feature's old path stays behind a flag until the new one passes its gate. Each flag has an expiry date in `plan.md`.
- [ ] Promises and interface text this release changes are updated in `operations.md`.
- [ ] {{OWNER}} approves the deploy.

## After deploy

- [ ] Confirm what is live: probe a route or value this release added.
- [ ] Run the main path on production with a real action. Where money moves, make a small real purchase and refund it.
- [ ] Check every conversion event on the live stream.
- [ ] Compare the error rate with the window before. If it diverges, flip the flag back first.
- [ ] Check each fail-closed switch (allowlists, feature gates) in production. One that was never configured drops everything silently.
- [ ] Log the check below.

| Date | Commit | Approved by | Result |
|---|---|---|---|
| | | | |
