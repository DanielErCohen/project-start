# {{PROJECT_NAME}} brief

The definition every other file serves. Where another file disagrees, this one wins. A change here is a product decision that {{OWNER}} confirms, made in the same piece of work as the change; git holds the history.

## What it is

*Two to four sentences: the thing, the person it serves and the change it makes for them. No feature list.*

## Who it is for

- **First user:** <one named kind of person>
- **Behavior that defines them:** *what they do today, leaving demographics out.*
- **Not for now:** <who is deliberately out>

## What it does

*Numbered capabilities in order of importance, one or two sentences each. Anything not listed is out of scope until this list says otherwise.*

1. <capability>

## What it does not do

*Boundaries that stop scope creep and name legal or safety lines. Each carries its reason, because a boundary without one gets argued away.*

| It does not | Because |
|---|---|
| <boundary> | <reason> |

## Beliefs

*What has to be true for the project to be worth doing. Write each "It is wrong if" result before any test runs, so a failed test changes the scope instead of being explained away. Order by how much scope falls if the belief fails.*

| # | Belief | It is wrong if | Status (stage, count, date) |
|---|---|---|---|
| 1 | <belief> | <result that proves it wrong> | proposed, untested |

## Kill lines

*The few measures that decide whether the project continues. Write them from the need they serve, never from a past best score. Check that the data for each measure exists before the test starts: a measure that cannot be read is "not measured", which never counts as passing. A failed line triggers one of three decisions, stop, pivot or rescope. It never triggers a new metric.*

| Measure | Threshold | Source | Read date | If it passes | If it fails |
|---|---|---|---|---|---|
| <measure, as a count first> | <number and unit> | <where the data comes from> | YYYY-MM-DD | <continue, with what> | <stop, pivot or rescope> |
