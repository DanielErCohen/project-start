# Privacy

The data position of {{PROJECT_NAME}}: what personal data exists, where it goes, who handles it, for how long. Write it before real personal data reaches a model, a test environment or a vendor; anything binding goes to a lawyer.

## Categories and storage

> ADAPT: fill from the interview and brief; delete the example rows.

| Category | Example fields | Sensitivity | Needed for | Store, region, who reads |
|---|---|---|---|---|
| Account | email, name | normal | sign-in | |

Record per category how long it is kept, what deletes it and how a person exports or deletes it. Card and bank data stays with the processor's hosted checkout. Health, children's and diary-like data leave the device only with a written reason.

## What may go into a chat

Default: none, and the agent asks. A bare "ok" does not answer on other people's data; the owner names what is allowed.

- **Allowed:** templates, anonymized or invented examples, totals, the owner's own notes.
- **Ask first, with the minimum fields:** anything that identifies a client, user or colleague (a name, email, an amount tied to a person, a case file). Only an approved vendor receives it.
- **Never:** passwords and keys, card or bank numbers, identity numbers, health data, children's data, or a whole file when one field would do.

An approved vendor is one whose terms the owner has read, with the date in the table below; in a company it must also be on the vendor list. Check any confidentiality duty first, such as a professional secrecy rule or a client contract that limits where files may go.

## Processors, model vendors included

| Processor | Receives | Terms read on | Retention there | Trains on it | Approved |
|---|---|---|---|---|---|
| | | | | | |

## Rules that apply

> ADAPT: list the regimes that bind this product by where its users or clients live, one row each with the source and the date read. Examples: the EU or UK (GDPR: a lawful basis, a contract with every vendor, limits on sending data abroad); US states; Canada; professional confidentiality; health, children's and payment data. Unclear rules go to a lawyer via `owner.md`.

| Regime | Applies because | What the product does | Source, date |
|---|---|---|---|
| | | | |

## Client files

Clients' personal files stay in {{OWNER}}'s own systems; the repository holds templates and anonymized examples. Anything that must sit locally goes in `private/`, which is git-ignored and denied to the Read tool, because a committed file cannot be taken back from every clone.

## Telemetry

> ADAPT: keep this section only when the product sends telemetry; otherwise delete it.

Telemetry counts as data. Analytics receives only values that describe what the product or the user did, with no free text.

- Scrub by allowlist: only named fields leave. A denylist misses what nobody listed.
- Test the scrub against the production build with the real SDK: seed fake personal values into the URL, body, user fields and breadcrumbs, trigger an error, and assert none arrive. A scrub tested only in development has failed in production.
- An event that cannot be scrubbed is dropped. Consent records are append-only: a withdrawal adds a row.

## Open items before the first outside users

- [ ] Consent text, processing agreements and privacy notice done
- [ ] Export and deletion tested end to end
- [ ] A support address that is read
- [ ] A lawyer's answer on anything binding
