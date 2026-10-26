# Module: open-source
Trigger: the code repository is public, or outside contributors are expected.
Adds: `.claude/rules/open-source.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `SECURITY.md`, `docs/releasing.md`.
## Append
- .gitignore | /project/
- CLAUDE.md | No project/ folder means you are a contributor: read README.md and CONTRIBUTING.md. Maintainers also follow .claude/rules/open-source.md.
- project/working-agreement.md | Publish a release: the owner, approval each time.
## Manual
- After the owner's yes, create a private repo for `project/` and clone it there. Commit it with `git -C project` at session close; a cloud session attaches it first.
- Keep `SOLO_PATHS="project"` in `.claude/hooks/guard.sh` as installed, so pushes inside `project/` pass.
- Install with `--mode human-review`. If review is installed, add a changelog line to its pull request template.
- Set the security contact in `SECURITY.md`.
Skip when: the repo stays private.
