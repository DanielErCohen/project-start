# Review criteria

For `/code-review`, `/security-review` and human reviewers. Report correctness and requirement gaps only, because a reviewer that lists every gap pushes the author into over-engineering.

## Report

- Defects: wrong logic, an unhandled branch (empty, duplicate, failed, offline, already done), an off-by-one, a race, data lost or shown to the wrong person.
- Requirement gaps: the change differs from the issue, plan item or `project/brief.md`.
- Each network or library call the change adds, given an error body without a message, an empty reply or a hang: these cause endless spinners and silent successes.
- A bug fix with no test that fails before the fix.

Skip style, naming and refactors.

## Severity

| Level | Meaning | Handling |
|---|---|---|
| Blocker | Loses or miscounts data, shows one person another's data, stops a core action, crashes, fails silently, breaks privacy or security | Fixed before merge |
| Major | Departs from the requirement while the task can still finish, or costs real maintenance soon | Fixed in this change unless the owner defers it in writing |
| Minor | Polish nobody meets | Follow-up; not re-reviewed |

## Profiles

> ADAPT: keep the profiles that match what the project exposes and delete the others.

Anything a person or program meets directly is at least a major when it is wrong, however small the fix, because people judge the product by what they meet.

- **Screens:** layout at every supported size, copy, accessibility, motion, and a feature not doing what it promises.
- **CLI:** exit codes (0 success, non-zero failure, a usage error apart from a runtime one), data on stdout and messages on stderr, and stable flag names and output format, since scripts depend on them.
- **API:** status codes that match the outcome, error bodies that say what failed, and backward compatibility: a removed or renamed field, a changed type or a new required parameter breaks existing callers.

## Rounds

1. Review in a fresh context after the checks pass. The diff is the unpushed commits in solo mode (`origin/{{DEFAULT_BRANCH}}..HEAD`, or every commit when there is no remote), and the diff against `{{DEFAULT_BRANCH}}` otherwise.
2. Fix blockers and majors, each with a test that fails without the fix. The author fixes while its context is small and fresh; otherwise a fresh agent does.
3. A second round only re-checks a fix for a defect the first found. Stop at two; a change that cannot pass goes back to scoping.
4. Drop a finding that contradicts `project/decisions.md`.

## Risk class

Payments, sign-in, personal data, storage and migrations: add `/security-review` and one review by a different model family or a domain reviewer from the approved set, with exit criteria written before round one. Reason: reviewers of one family share blind spots. The approved set is the vendors and people the owner allows; a project limited to one model vendor uses a domain reviewer.

## Output

A one-line verdict (ship, fix blockers first, rework), then findings, most severe first, as `file:line | level | finding | fix`.
