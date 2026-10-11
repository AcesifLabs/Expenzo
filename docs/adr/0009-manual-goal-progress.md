# ADR 0009: Goal progress is entered by hand

## Status

Accepted

## Context

Onboarding adds a savings Goal. Progress could be derived from a savings budget, income minus expense, or tagged Records, but each risks double counting and confusing totals.

## Decision

A Goal stores `savedAmount`. The user raises it with "Add to goal" on the dashboard card. Goals never read Records or Budgets, and a Goal Contribution creates no Record. Goals sync like Budgets.

## Consequences

### Positive

- No double counting; the number is exactly what the user entered.

### Negative

- Progress goes stale if the user forgets to update it.
