# ADR 0014: Amounts stay double, rounded to 2 decimals on write

## Status

Accepted

## Context

Amounts are stored as SQLite REAL and rounded only when displayed, so long sums pick up float error (`0.1 + 0.2 != 0.3`). Integer minor units (paisa, cents) would remove the error but change every amount column, the sync payloads and the backend.

## Decision

- Amounts stay `double` in Dart and REAL in SQLite.
- Every repository write rounds to 2 decimals first. SQL sums are rounded to 2 decimals when read.
- Tests compare totals with a 0.005 tolerance against an integer-cents reference.
- Moving to integer minor units is deferred to its own project.

## Consequences

### Positive

- No schema or sync change. Stored values never carry more than 2 decimals.

### Negative

- Totals over many rows can still differ from exact decimal maths by less than half a cent before rounding.
