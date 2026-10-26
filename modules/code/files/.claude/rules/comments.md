---
paths: ["src/**", "app/**", "lib/**", "packages/**", "scripts/**", "tests/**"]
---
# Comments

> ADAPT: set `paths` above to this repo's source folders and add the language's doc-comment syntax to the delete list.

A comment says what the code cannot. The default number of new comments in a diff is zero, and each one kept passes the test at the end.

Keep:
- The reason behind a business rule, a constraint or an unidiomatic line.
- A link to the source of copied code, a spec, a platform quirk or an upstream bug.
- A bug-fix note naming the failure mode, so it is not reintroduced.
- `TODO: <what is missing> <issue link>` for an incomplete part, with no person's name in it.

Delete on sight:
- Narration of the next lines, a restatement of the function below it, thinking out loud, and commented-out code (git holds history).
- Doc comments that repeat the typed signature.
- Dated or comparative notes about past versions ("previously we", "no longer used"). State the current reason or delete it.

Test before keeping a comment: delete it. If a competent reader loses nothing the names, types and code do not already carry, leave it deleted. If a clear comment is hard to write, the code is unclear: rename or split.
