# ADR 0017: Matching rules are removed; SMS parsing uses SMS Formats only

## Status

Accepted. Supersedes the matching-rules parts of ADR 0006 and ADR 0015.

## Context

Matching rules were user-written regular expressions tried when no SMS Format matched a monitored sender's message. They needed regex knowledge, had their own editor and tester, and stored a separate synced table. The Settings page that managed them is replaced by the SMS Watchlist. Keeping the evaluator without the page would let rules nobody can see or edit keep creating Records.

## Decision

- The rule evaluator fallback, the `parsing_rules` table, its sync handler and the backend `parsing_rules` table are removed.
- Mobile schema v21 drops the table and any queued rule changes. A backend migration drops the server table.
- SMS from a monitored sender becomes a Record only when one of that sender's SMS Formats matches.

## Consequences

### Positive

- One way to teach the app a message shape, built from a sample message instead of a regex.
- Less code, one fewer synced table.

### Negative

- Messages that only a rule matched stop creating Records; the user has to add an SMS Format for them.
- The app is unreleased, so the backend drops the table outright. A client on an older build that still pushes `parsing_rules` changes has its sync batch rejected.
