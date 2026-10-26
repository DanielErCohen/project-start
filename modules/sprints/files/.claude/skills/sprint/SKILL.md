---
name: sprint
description: Run several changes as one sprint. Use at session start when a sprint file exists, to plan a sprint when none covers the next work, and to close one when its changes are merged or parked and the owner says to close.
argument-hint: start | plan | close
---
# Sprint

A lane is one independent piece of work inside a sprint: it has its own done-when item, its own checks and review, and merges on its own.

## Start (every session)

1. Read `project/owner.md`; apply each answered item to the files that depend on it, and say which.
2. Read the newest sprint file's status table and handoff, `project/plan.md` and the open questions in `project/decisions.md`.
3. Compare the handoff's commit with `git log --oneline -5`. A mismatch means someone worked after the handoff; find out what first.
4. Work the handoff's first actions; update the status table after each merge.

## Plan (last sprint closed)

1. Recon: read-only subagents on Haiku, one per independent question.
2. Write `project/sprints/YYYY-MM-DD-name.md` from `_template.md`: done-when items a command, test or walk can check, a reason per exclusion, lanes in build order.
3. Challenge the plan in a fresh context (a subagent on Opus): are the done-when items checkable, does the lane order hide a dependency, does each claim about code hold at the named commit? Fold blockers and majors in.
4. Ask the owner "This sprint builds A, B and C. Default: yes." List it in `project/owner.md` and build on the default.

## Build

The main session codes the lanes in turn. With review, cut each branch from `{{DEFAULT_BRANCH}}` after the previous lane merged, because a branch cut from another lane met conflicts with that lane's squash. In solo mode there are no branches: commit each lane in order on `{{DEFAULT_BRANCH}}`.

Run lanes in parallel only when they share no file and no stored data, each as a subagent with `isolation: worktree` and `model: sonnet`, whose brief restates the must-hold rules.

Per lane: gate, `/code-review` (on the unpushed commits in solo mode), merge per the merge mode or push in solo mode, update the status table. After the last merge run the full gate on `{{DEFAULT_BRANCH}}`, since a clean textual merge can still break behaviour.

## Close

1. Workspace: remove idle worktrees, delete merged branches (squash merges are missing from `git branch --merged`, so use the host's merged-change list), stop servers.
2. Run the gate on the merged tree; walk what a person sees or uses with `qa-tester`, if the walks module is installed.
3. Bring `project/` files and `docs/` in line with what merged.
4. Write the handoff from `_handoff.md` last, because merges keep landing while it is written.
5. Cold check: a fresh Haiku subagent reads only the handoff, lists each claim a command shows wrong and what it needs and cannot find, and edits nothing. Fix each finding.
6. Give each lesson one home (a rule, a hook with a test, the working agreement) after a grep finds none. A rule stays while a failure motivates it. Trial a changed rule on named tasks before calling it better; a repeated pattern becomes a rule with the owner's yes.
7. Commit by path and report: bottom line, then what waits on the owner, each with its default.
