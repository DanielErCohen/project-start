---
paths: ["src/ai/**", "**/prompts/**", "evals/**", "functions/**"]
---
# Model calls and evals

> ADAPT: set `paths` to where model calls, prompts and the eval set live.

## In the product

1. Code computes, the model words. Every number, date, rule and decision comes from deterministic code; the model phrases, summarises or fills free text. A model doing arithmetic is sometimes wrong, unseen.
2. Validate each response against the job's schema before use. On failure retry once, then fall back to a second model from the approved vendors (or the same model with a simpler prompt when only one is approved), then to a non-AI default. An unvalidated reply never reaches storage or a screen.
3. Send the minimum context: no secrets, other users' data or unneeded fields, and keep full prompts out of logs.
4. The model never produces figures shown to the user, safety-critical text or claims about history it was not given. Code detects safety cases before any call and answers with fixed text. The model never sets a flag recording a person's confirmation.
5. One module calls the provider behind a small interface, with model per job in settings.
6. Keep the old path behind a flag, with an expiry date, until the new one passes its eval. A deleted old path leaves no rollback.
7. Tests use fixtures. A per-user, per-day cost cap sits in code.

## States

8. Empty, failed and degraded are three results. A pipeline compares its output count with its input count and reports a shortfall as degraded. A null from an outage is never an answer, and a missing optional dependency fails loudly. A run that lost half its work can score higher than a complete one.

## Measuring

9. Pin the measuring instrument: judge model version, rubric version and headline formula, recorded in `project/decisions.md`. A changed instrument breaks comparison with earlier rounds, so start a new series.
10. Measure drift by re-scoring a frozen artifact blind, without its earlier score, whenever the judge changes.
11. Write the pass line before the run, from the user's need, and ignore past best scores. A failed line triggers a decision (stop, pivot or rescope) and the metric stays.
12. Every eval run has a cost cap and runs the riskiest case first, so a capped run still tests what matters most. A prompt, model or schema change runs the eval set, with the result in the change description.
