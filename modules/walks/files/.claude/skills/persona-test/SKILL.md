---
name: persona-test
description: Code-blind simulated users drive the real product through realistic journeys; a synthesis pass re-checks and tiers their findings. Use when the owner asks for a persona test, a simulated UX test, or how a flow feels to a user.
argument-hint: [personas or journeys; empty for all]
---
# Persona test

Findings are leads for the owner to confirm, because personas cannot feel waiting or interruption. Stop and name what is missing if the control tool is absent or the product does not run on the real target. Use test data only.

## Personas

Write each as a card in `project/personas.md`: who, goal, device and settings, patience, any assistive setting. Ground it in dated research or real feedback.

## Sessions, one persona at a time

1. Spawn a subagent on Haiku at medium effort with no file-reading tools, and repeat the limits in its brief. A persona that can read code stops being a stranger.
2. Start from fresh state, with no reset or rebuild during the session.
3. The brief gives the card; a view limited to screenshots or terminal output; the rules to state intent before each action, quote the screen after, and give up when patience runs out; the driving rules from `qa-tester.md`; the tasks; the report path. The persona drives the product and never describes what it would do.

## Tiers

- **Defect:** observed and reproducible, with steps, result and expectation.
- **Friction:** completed at a cost, with taps, waits and re-reads counted.
- **Hypothesis:** suspected and unconfirmed.
- **Harness:** the setup broke; reported apart from the product.

Each claim cites a log step, quoted screen text and a saved frame.

## Synthesis (the main session may read code)

1. Drop findings that cite code. Re-check each defect through `qa-tester`; drop or downgrade one that does not reproduce.
2. Merge duplicates, crediting each persona. A complaint about a decision in `project/decisions.md` is reported as that.
3. Challenge the survivors: which stem from the persona's artificiality or the harness?
4. Rank by severity times personas affected. A persona's product idea is no defect.
