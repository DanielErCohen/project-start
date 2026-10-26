# Docs

A doc lives in this folder only if an engineer needs it to work on the code. Everything else (product, plans, decisions, status, account setup) lives in `project/`. The split keeps the code docs true: status and plans rot within weeks, while an invariant stays true as long as the code does.

- State what the code cannot: invariants, the reason behind a structure and how to extend it. Name the file that holds a value, list or schema instead of copying it.
- No dates, status, progress, plans or history; git and `project/` hold those.
- A change that makes a doc wrong updates it in the same change. A doc nobody needs any more is deleted.
- Each doc names the code it covers in its first line, so there is no index to maintain.
