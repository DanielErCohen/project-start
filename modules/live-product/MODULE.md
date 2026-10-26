# Module: live-product
Trigger: the product has paying customers or public users.
Adds: `project/operations.md`, `project/release.md`, `.claude/rules/migrations.md`, `.claude/rules/production-access.md`.
## Append
- CLAUDE.md | Live product: project/operations.md lists the promises we keep; read .claude/rules/production-access.md before touching production.
- project/working-agreement.md | Production data read: the owner, per named question.
- project/plan.md | Queue: flow mode, see project/operations.md; when sprints are installed the sprint file is the queue.
## Manual
- In `.claude/hooks/guard.sh` add the stack's migration-apply and deploy commands to `PROD_PATTERNS`, with a test case each.
- Set `paths` in `migrations.md` to the stack's migration folder.
- If `no-code` also installs, both add `project/operations.md`: keep one file, the no-code cycle sections first, then these.
Skip when: nobody outside the team uses the product yet.
