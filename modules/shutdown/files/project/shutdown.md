# Shutdown

Status: stop decided on <date>, logged in `decisions.md`. Work down the list, and after each step write its date and result beside it. Change the status to "Stopped" with the date when the last step is done.

> ADAPT: add this project's vendors, stores and addresses. Mark steps that do not apply and say why.

1. **Notice.** Tell users and API clients early: the reason, the stop date, what happens to their data, how to export it. Contracts set minimum notice periods. The agent drafts and {{OWNER}} sends.
2. **Export.** While admin access works, export customer data in a machine-readable form (people have a right to this for data held under consent or contract), and your own records: invoices, payouts, tax papers.
3. **Backup and restore.** Back up the database, file storage and configuration (setting names, with values left in the secret store). Restore into a scratch environment and compare counts. Delete nothing before the restore works.
4. **Not backed up.** List everything outside the backup with its fate: storage buckets, third-party dashboards, logs, analytics, mailing lists.
5. **Redirects and domain.** Point the old address to a notice page. Map DNS records and hardcoded dependencies (webhooks, email senders, app links). Keep the redirect (domain and certificate) for one year or until the certificate expires, whichever comes first.
6. **Stop command that holds.** Stop each service with a command whose effect persists. Some scale-to-zero commands do not hold, and a plan fee may continue. Record the command.
7. **Recheck.** After a delay (next day, then a week) read the public endpoint again and record what it returned.
8. **Vendor wind-down.** One line per vendor in the list below. A dashboard-only action goes on `owner.md` with exact steps.
9. **Data deletion.** After the notice period and any legal retention, delete stored personal data and the backups on the same schedule. Check each vendor's deletion window.
10. **Keep the code.** Archive the repository read-only and write the restart steps below.
11. **Freeze.** Change nothing and restart nothing without {{OWNER}}'s ask. Agents read this page first.
12. **Repair pointers.** Update the README, the brief and any note that still says the project is live.

## Vendor wind-down

One line per vendor: what it holds, the action (downgrade, cancel, delete), the date, who does it.

## Restart steps

Written now, while the knowledge is fresh: settings to restore, order of services, migrations, DNS.
