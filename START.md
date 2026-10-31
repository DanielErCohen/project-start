# Start

For the agent that was told to start a project from this folder. Read it fully, then work the phases in order.

## Three duties

1. **Challenge what you received.** That includes this template. Check each file against the project, and drop what does not fit. Model names, commands and tools here are dated October 2026: confirm them on this machine (`claude --version`, a dry run) before writing any into the project.
2. **Customize it with the owner.** Recon first, skip every question a file answers, then ask one at a time, each with a default and its reason in one clause. List the defaults you took.
3. **Challenge the owner** on product, stack, scope, money and privacy where they apply: your assessment as a fact, the strongest counter, one recommendation. The heuristics sit inline in [QUESTIONS.md](QUESTIONS.md).

## Stance

- Technical points are yours: decide, with the reason in one line.
- Ask before anything irreversible or that reaches another person: a remote, a push, accounts, spending, messages. Local installs are cheap: do them and report.

## Built-ins this flow uses

Plan mode holds the proposal; without it, write nothing before a yes. Read-only subagents (Explore, or `model: haiku`) do recon. `/init` surfaces build and test commands. `/code-review` runs after the first code change; `/security-review` needs an `origin` remote, so it waits for the owner's yes to one. Commands only a person can type (`/model`, `/context`, `/doctor`, Shift+Tab) are batched into one request at Verify. Auto memory carries what Claude learns; add no notes system.

## Phases

A phase starts after the previous exit is met.

**1. Read.** This file and QUESTIONS.md. List `core/` and `modules/` by name; open a file when a phase needs it.
Exit: three lines on what the template holds and what you have not read.

**2. Recon.** Find out what exists before asking. Look at the target folder and its siblings, anything the owner pasted (read it fully), manifests, scripts and CI for commands, the default branch and remote, whether the repo is public, existing CLAUDE.md, rules, hooks and settings, and the machine: system, shell, git and a working Python. In a cloud or phone session skip the machine checks and say so. Use read-only Haiku subagents, told to run the commands they cite and report only what they saw; check load-bearing findings yourself.
Exit: a list with source and state (found, missing, unclear) per field.

**3. Interview.** Map any pasted document onto the fields (see "Bring your own questionnaire"). Ask the "Default: none" fields first, one at a time, then field 11, so the remote question comes early. Park what the owner cannot answer yet: the default stays and the item goes to the open questions in `project/decisions.md`. Check dictated names, numbers and dates against recon. Stop when the remaining defaults are good enough.
Exit: all 12 fields answered or defaulted, defaults listed.

**4. Challenge.** Raise each red flag once, with the one fact that would settle it. When the owner overrules you with no new information on a decision that is theirs, log it in `project/decisions.md` and go on. Settle the merge mode (default `solo`: push on the default branch, no pull requests) and the decision rights.
Exit: every flag raised once, overruling logged, merge mode agreed.

**5. Propose.** Stay in plan mode. One screen, bottom line first:
- modules chosen and the field that triggered each;
- defaults taken;
- what is left out and why;
- what waits for a yes: a remote, the first push, accounts, spend.

Exit: a yes, or a yes with changes (show only changes).

**6. Install.** Start from a clean working tree. Run `sh <path>/tools/install.sh --target . --mode solo --modules a,b` with the agreed mode, and `--code` for a code project. It applies the mode and each module's wiring lines, and never overwrites: for each listed `.project-start` file, show the diff, merge and delete the copy. On Windows use Git Bash. Then:
- fill every `{{TOKEN}}`; a command that does not exist yet stays empty and the check script reports SKIP;
- do the manual steps the installer printed for each module;
- set the working agreement's permission mode and sandbox row from field 11 (auto mode or approval prompts, sandbox on or off);
- rewrite every `> ADAPT:` passage and delete the callout;
- fill the `project/` files from the answers, with the models table dated;
- delete any section that does not fit.

Commit locally with `git add <paths>` and `git commit`, never `-a`. Create no remote and push nothing without a yes.
Exit: every file is on disk and committed.

**7. Verify.** Run `sh <path>/tools/verify.sh --target .`; every check passes or skips with a stated reason. Send the owner one request for the commands only they can type: `/context` (CLAUDE.md loads), `/doctor prompt-audit` (conflicts), `/model` (the table's models exist here) and Shift+Tab to the permission mode the working agreement names; ask them to paste the output. Meanwhile run the cold read: a fresh Sonnet subagent with no conversation context, pointed only at the installed project, told to run any command it cites. It reads CLAUDE.md and what that points to, then answers in writing:
1. What is the product and who is it for?
2. What is the first step and what ends it?
3. What may you decide alone, and what must you ask the owner?
4. Where do you record a decision, a question for the owner and a lesson?
5. Which commands make up the check?

It also lists every broken link, leftover token, contradiction and gap. Fix them, then stop: one cold read, one fix round.
Exit: verify passes, the owner's output shows no conflict and the five answers match.

**8. First step.** Take the riskiest belief in `project/brief.md`. A learning project has one review date and no kill line. If it is demand or behavior (will people use it, pay, come back), test it first with a prototype, a concierge run (you do the work by hand for a few people) or interviews. If the risk is technical, build the smallest path from input to output on the real target with the check green. Write the kill line before the test, confirm its data exists, and put a spend line, model cost included, on the plan item. Ask one scope question with a default.
Exit: the first item in `project/plan.md` has a done-when and a kill line (or the review date).

**9. Report.** One screen:
- what is installed, which modules, the state;
- what waits on the owner alone, one line each (steps in `project/owner.md`);
- defaults that matter, and doubts about the template;
- the first step and its scope question.

Exit: a session that never saw this chat can continue from the files.
