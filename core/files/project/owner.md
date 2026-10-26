# Owner

Only what is blocked on {{OWNER}}: sign-ins and paid sign-ups, other people, and the product, brand and money calls. Claude is the only writer of this file and refreshes it at every session close, so a phone reader sees the current list.

> ADAPT: rules for Claude when writing this file.
> - Each item is a plain title in simple English, expanded into every step {{OWNER}} takes: the site, the menu, the button and what to paste where. {{OWNER}} should never need to come back and ask.
> - Each item ends with `Default:`, what happens if {{OWNER}} does not answer, and says what it blocks.
> - Engineering choices never appear here. If the answer is "Claude can decide", it is not an item.
> - A finished item is deleted; git holds the history. Answers {{OWNER}} leaves count as done and are applied at the next session start.

## Waiting on you

### 1. <Plain title>

*Why it matters in one sentence, and what it blocks.*

1. Open <site or app>.
2. Click <menu>, then <button>.
3. Paste <value> into <field>.
4. Tell Claude "<exact reply>".

Default: <what happens if you do not answer>.

## Decisions for you

*One product, brand or money call per item: the question, the strongest counter, one recommendation and `Default:`. The scope question for the next piece of work comes first.*

### 1. <Question>

- **Recommendation:** <the option and the reason>
- **Strongest counter:** <the best argument against>
- **Default:** <what happens if you do not answer>

## Where accounts and secrets live

*One home per secret, so a rotation touches one place and a leak has one source. A secret value is never written in this repository or in chat.*

| Account or secret | Home | Who holds the login |
|---|---|---|
| <name> | <dashboard, password manager or local env file> | {{OWNER}} |
