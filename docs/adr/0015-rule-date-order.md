# ADR 0015: Parsing rules read numeric dates as day/month by default

## Status

Accepted

## Context

The rule evaluator read `05/10/2026` as May 10 and returned null for `25/10/2026`. Banks in Bangladesh and India send day/month dates. Impossible dates such as Feb 31 were rolled over into March by `DateTime`.

## Decision

- A parsing rule has a Date Order: `dmy` (default) or `mdy`. The rule editor shows it.
- An all-numeric date is read using the rule's Date Order. Month-name dates (`05-Oct-2026`) are read without it.
- Impossible dates are rejected: the parsed day, month and year must match the built date, otherwise the date is null and the message date is used.

## Consequences

### Positive

- Bangladeshi and Indian bank dates parse correctly without per-rule setup.

### Negative

- A bank that sends month/day needs its rule switched to `mdy` by hand.
