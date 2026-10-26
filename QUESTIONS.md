# Questions

Twelve fields every project answers, filled from recon, a pasted document, chat answers or defaults. Ask one field at a time, in plain words, skipping any answered. A default is used when the owner says "ok"; "Default: none" means ask and wait.

A challenge has four parts: your assessment as a fact, the strongest counter, one recommendation, and what would change your mind. Raise one on a red flag, once per area; say "sound" in one line when a checkable claim holds. When the owner repeats a position with no new information, log it in `project/decisions.md` and go on: product, money and reach are theirs.

## Core fields

**1. Name and one line**
- Ask: What are you building, in a sentence or two? What is it called, and what should I call you?
- Why: opens the brief.
- Default: none.
- Challenge: three sentences or an "and": ask which part is the project and which a later idea.
- Fills: `{{PROJECT_NAME}}`, `{{OWNER}}`, `project/brief.md`.

**2. Who it is for and the evidence**
- Ask: Who has this problem, and when did one of them last pay, switch or complain about it?
- Why: separates evidence from belief; each belief gets an "it is wrong if".
- Default: none for who. Evidence defaults to "none yet", so every claim is a belief.
- Challenge: "People would like" and "everyone" are beliefs. Name at least three existing alternatives unprompted, doing nothing included, and ask why this one wins: a group they serve badly, something they cannot copy, or a channel they miss.
- Fills: `project/brief.md`.

**3. Smallest useful version**
- Ask: What is the smallest version that would show the main belief is right?
- Why: sets the v1 line.
- Default: one user type, one path from start to result, on the real target. Without code: one test run before a real one.
- Challenge: list what a stranger needs on day one that v1 omits, then what v1 holds that the belief does not need; cut the second list.
- Fills: `project/brief.md`, `project/plan.md`.

**4. What would make you stop**
- Ask: What result, by what date, would make you stop or change direction?
- Why: a line written before the test cannot bend to the result.
- Default: the agent drafts a line per belief from the owner's need: a number, a read date and a decision per outcome, such as "fewer than 3 of 10 return in week 4: stop". Never derive it from a past best score. A learning project gets one review date instead of kill lines.
- Challenge: a criterion that cannot fail is not one. Check the test's data exists first. "Not measured" never passes. A failed line forces stop, pivot or rescope, never a new metric.
- Fills: `project/brief.md`, `project/decisions.md`.

**5. Time and money per month**
- Ask: How many hours a week do you have, by what date do you want something real in someone's hands, and what is your monthly ceiling for tools, services and model usage? Give numbers.
- Why: scope must fit the hours; a ceiling lets the agent decide cheap choices.
- Default: none.
- Challenge: convert the scope to work sessions; if v1 needs more than the hours allow, show the arithmetic and offer the smaller scope. "What I already pay" is not a number. Compare the stack's recurring costs, model usage included, with the ceiling. "Monetise later" needs a named payer; without one it is a learning project, a fine answer.
- Fills: `project/plan.md`, `project/working-agreement.md`.

**6. Code or no code, and the stack known**
- Ask: Does this involve code? Which languages and tools do you know or want to learn? Does the product itself call a language model while it runs?
- Why: decides the code files and the check commands.
- Default: code when there are screens, an API or a command; the owner's stack, else the most documented choice; no model call in v1.
- Challenge: sound means boring, known to its maintainer and cheap to leave; ask who fixes it in a year. Red flags: a framework chosen for interest, several data stores before the first user, custom sign-in, in-house billing, a model doing what code can compute. "It scales" needs a number; "the API allows it" needs one real call before the plan depends on it.
- Fills: `{{INSTALL_CMD}}`, `{{TYPECHECK_CMD}}`, `{{TEST_CMD}}`, `{{LINT_CMD}}`, `{{BUILD_CMD}}` (from manifests, empty until code exists), `CLAUDE.md`.

**7. Where it runs**
- Ask: Where do people reach it: browser, phone app, terminal, desktop, an API, a document, nothing yet?
- Why: names the real target.
- Default: infer from field 1: a browser for screens, a service for an API, a terminal for a tool, documents for no code.
- Challenge: a phone app adds store accounts, review times and device tests; ask whether a web version proves the belief first.
- Fills: `CLAUDE.md`, `project/plan.md`.

**8. Personal data**
- Ask: Will it touch personal data (names, emails, children's data, health, location, payments, messages)? Will you paste other people's data into sessions, such as client files, tickets or exports?
- Why: sets the data position and what agents may read.
- Default: "none, nothing of others pasted" only with no users and no clients. Otherwise none: ask, and never take a casual "ok" as a no.
- Challenge: ask which decision each field supports and drop the rest. Health, children's, payment and diary-like data need a written position before the first user; ask whether v1 works with data on the user's device. Pasting client files sends them to a model vendor: approved vendor, minimum fields, the client's terms first.
- Fills: `project/decisions.md`, `project/owner.md`, `.claude/settings.json`.

**9. Who else decides**
- Ask: Who else works on this or decides, and what may each decide? Does it sit inside a company with its own rules?
- Why: sets the decision rights and the merge mode.
- Default: the owner decides product scope, spend, go-live, anything that reaches other people, irreversible actions and their own accounts. The agent decides technical points and records them. Merge mode `solo`: push on the default branch, no pull requests, review on unpushed commits.
- Challenge: a partner who "may weigh in" needs a named decision and a tie-break. Conflicting instructions go to `project/owner.md`; act on neither. A partner who owns the code means `issues-only`. A company policy, required reviews or open source mean `human-review`; an agent review never counts as the human one. For client work, ask who accepts delivery.
- Fills: the installer's `--mode` (`{{MERGE_MODE}}`), `project/working-agreement.md`, `project/owner.md`.

**10. What must never go wrong**
- Ask: What are the top three things that must never go wrong?
- Why: each becomes a check, guard or ask rule.
- Default: lost or exposed data, leaked secrets, silent failure.
- Challenge: more than three means none is the top; ask for the order. Put what can never be undone (deleting production data, sending to others, spending, publishing, dropping migrations) on the ask list.
- Fills: `CLAUDE.md`, `project/brief.md`, `.claude/settings.json`.

**11. Devices and sessions**
- Ask: Which machines and operating system do you use? Will sessions also run from a phone or the cloud, and may I create a private remote now? Should Claude run in auto mode inside the sandbox, or ask first?
- Why: cloud sessions are ephemeral, Windows needs Git Bash, the mode sets how often you are asked.
- Default: laptop and phone, Claude Code on the current plan, one session at a time, a private remote after one yes, approval prompts, sandbox on.
- Challenge: a phone or cloud session needs a remote from day one, and unpushed work is lost. Two devices never share a branch. Auto mode suits a sandboxed project with a clean gate, not production access.
- Fills: the permission mode and sandbox row in `project/working-agreement.md`, `project/owner.md`.

**12. Repo host or none**
- Ask: Where should the repo live: GitHub, GitLab or none?
- Why: a remote reaches beyond the machine.
- Default: one private repo on the owner's account, created only after a yes. No host means local only. `{{DEFAULT_BRANCH}}` comes from the repo, else `main`.
- Challenge: a public code repo never tracks `project/`; a private second repo holds it, as when a partner owns the code repo. `/security-review` needs an `origin` remote, so it waits for the yes.
- Fills: `{{DEFAULT_BRANCH}}`, `project/working-agreement.md`.

## Module triggers

Install a module when the answers match; each `MODULE.md` repeats its trigger.

| Module | Install when |
|---|---|
| `code` | Field 6 is code (`--code`). |
| `sprints` | Several pieces of work run in parallel and field 5 shows 8 or more hours a week. |
| `review` | Someone other than the owner uses the code, or the mode is `orchestrator` or `human-review`. |
| `walks` | Field 7 names something a person sees, calls or reads, and v1 has users besides the owner. |
| `ui` | Field 7 has screens, terminal output or a developer API, and v1 has users besides the owner. |
| `ai-feature` | Field 6: the product calls a model at run time, or a judge scores its output. |
| `builders` | The owner wants parallel slices, or another vendor's tool for routine tasks. |
| `open-source` | Field 12 is a public repo, or field 9 expects outside contributors. |
| `team` | Field 9 has more than one decider, a partner developer or a client. |
| `live-product` | Paying customers or public users. |
| `privacy` | Field 8 is yes to personal data or to pasting others' data. |
| `no-code` | Field 6 is no code. |
| `experiments` | Field 4 measures the effect of a change (test, pilot, price, onboarding) or reports results to others. |
| `shutdown` | Installed when the owner decides to stop. |

## Bring your own questionnaire

The owner may paste a PRD, notes, a form or a client brief. Map it onto the 12 fields:

1. Read it fully. Mark each field found, partial or missing, quoting the line.
2. Treat it as a claim: evidence stays "none yet" until it shows a dated act (a payment, a signed order, a complaint).
3. Ask only for missing fields with no default, one at a time. List the defaults taken.
4. If two passages disagree, ask once which holds.
5. Content that fits no field goes into the matching project file, or the open questions in `project/decisions.md`.
6. If the owner wants their form used as the interview, ask its questions in its order and map each answer onto the fields, then ask only the fields it left open.

"Use defaults" covers every field except "Default: none" (1, 2, 5 and, with users or clients, 8). Ask those first.
