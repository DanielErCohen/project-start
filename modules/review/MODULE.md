# Module: review
Trigger: someone other than the owner uses the code, or the merge mode is orchestrator or human-review.
Adds: `REVIEW.md`, `.github/pull_request_template.md`, `.github/workflows/check.yml`, `.gitlab-ci.example.yml`.
## Append
- CLAUDE.md | Review: after the checks pass, run /code-review once, judged by REVIEW.md; risk-class changes also get /security-review.
- project/working-agreement.md | Review merge rule: in solo mode review the unpushed commits before pushing; in orchestrator mode merge when the checks pass and REVIEW.md shows no open blocker or major; in human-review mode a named person approves and an agent review never counts.
## Manual
- GitHub: delete `.gitlab-ci.example.yml`. GitLab: rename it to `.gitlab-ci.yml`, delete `.github/workflows/`, and copy the pull request template to `.gitlab/merge_request_templates/Default.md`.
- Add the stack's setup steps to the CI file, then require the check in branch protection.
- Delete the `REVIEW.md` profiles the project lacks.
Skip when: only the owner uses the project and nothing is merged.
