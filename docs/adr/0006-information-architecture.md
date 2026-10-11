# ADR 0006: Four tabs; Auto-import and Recurring live in Settings

## Status

Accepted

## Context

The bottom navigation had Home, Activity, Scan and Budgets. Reports, the main payoff, was hidden behind a "See all" link, and the SMS Scan tab held a setup task most users do rarely. Recurring transactions and parsing rules were built but unreachable. There were three different "add" patterns.

## Decision

- Tabs: Home, Activity, Budgets, Reports.
- One center add button on every tab opens the Transaction Sheet.
- Settings hosts Auto-import from SMS (senders, scan past SMS, SMS formats, matching rules) and Recurring.
- Home shows a one-time "Set up auto-import" card until dismissed or permission is granted.
- The profile menu holds only profile/sign in, Settings and sign out.

## Consequences

### Positive

- Core tasks are one tap away; hidden features become reachable.

### Negative

- Users of the old Scan tab need the Home card or Settings to find auto-import.
- `?tab=scan` links fall back to Home.
