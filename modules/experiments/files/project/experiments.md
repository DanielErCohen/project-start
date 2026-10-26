# Experiments

How {{PROJECT_NAME}} tests a change and reports a result. Decisions are written before the data exists, because a criterion written afterwards is fitted to the data.

## Evidence stages

Every claim about a result carries its stage, a unit, a date and a basis.

1. **Proposed:** an idea or plan.
2. **Delivered:** it shipped, on a date.
3. **Reported:** someone says it worked ("the client says orders rose").
4. **Measured:** a number with its basis ("3 of 12 testers finished, week 2").
5. **Verified:** confirmed in an independent downstream source (the payment processor shows the same count).

"Shipped" never stands for "adopted" or "improved". Write rates as counts first: with few participants one person moves a rate by many points.

## The card

Fill every field before the test starts; a test with an empty field is not ready.

| Field | Content |
|---|---|
| Question | one sentence |
| Primary metric | numerator, denominator, window, filter |
| Guardrail | up to two metrics that must not worsen, with alert and block thresholds |
| Holdout | the share who never get the change, for how long, and what it teaches |
| Minimum run | days and count before any read |
| Read date | the single date the result is read |
| Freeze | no change to product, audience or metric until the read date |
| Data check | the date someone confirmed the metric can be computed from data that exists |
| Kill line | the result at which we stop, set from the user's need with no reference to a past best score |
| Decision per outcome | win / flat / loss / not measured: what happens for each |

## Rules

- "Not measured" is never passing. A metric that cannot be computed on the read date counts as a failed line.
- A failed line triggers a decision: stop, pivot or rescope. A new metric is not one of the options.
- The freeze holds to the read date: a new segment, redesign or price change mid-read mixes the cohorts.
- One primary metric and at most two guardrails, because each added metric multiplies the outcomes to decide in advance.
- Log any override in `decisions.md` with its reason.

## Log

One line per card: name, start, read date, outcome, decision, stage reached.
