---
paths: ["**/*.test.*", "**/*_test.*", "**/test_*.*", "tests/**", "test/**", "spec/**"]
---
# Testing

> ADAPT: set `paths` above to this stack's test files and add the runner notes. Examples: Node or TypeScript: `*.test.ts` next to the code, Vitest or Jest; Python: `tests/` with pytest.

- Tests sit next to the code or in the one folder the stack expects. They use no network, wall clock or randomness: pass time and ids in, so a test gives the same answer on every run. Pin the locale and time zone in the test command.
- A change ships with its tests on the main path, plus every failure branch of a write and every guard on personal data, permissions or money.

| Change | Test work |
|---|---|
| Bug fix | A test that fails before the fix, written first, naming the failure mode |
| Changed rule | Update the tests that encode the old rule; a rule change that breaks no test was untested |
| Anything that computes a number a person sees | Boundaries: zero, exact edges, maximums, past the end |
| New or changed schema or access rule | A test against the real data layer that proves the guard holds |

- Name a test after the module and the behavior: what it does, when.
- Mock only external boundaries (the database client, the network, the clock), at the repo's own interface, which survives an SDK swap. A mock keeps a spy that asserts the arguments, because without it deleting the call passes every test.
- Never weaken an assertion to make a test pass: fix the code, or state why the expectation changed.
- Assert observable behavior with explicit properties. No snapshots for domain logic and no assertions on call counts or private state, because they break on harmless refactors.
