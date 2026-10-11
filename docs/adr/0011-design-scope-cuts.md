# ADR 0011: Design screens we will not build

## Status

Accepted

## Context

`packages/mobile/design/expenzo.pen` includes screens that need systems the app does not have (payments, public API, analytics, email) or that cost more than they return.

## Decision

Not built:
- VIP badges, API (Developer Tools), AI Input Toolbar screen
- Password (sign-in is Google only)
- Data Sharing (no analytics or crash SDK)
- Email and generic push notification toggles, Sound effects
- Hijri calendar, week numbers, alternate app icons
- Backup frequency (sync is continuous)
- Assigning one Record to several Budgets
- Product price lookup in the onboarding Goal step
- Font family choice (the app uses Lato only, DESIGN.md)
- Apostrophe and "no separator" digit grouping (comma, dot and space only)
- "Reset to Default Categories"
- PDF export and exporting settings (CSV of transactions, budgets and categories only)
- "Drag to adjust" on the onboarding budget plan (fixed 50/30/20 split)
- QR code on the family invite screen (the code is shared as text)
- "or documents" on the dashboard receipt banner (receipts only)
- Wording the design uses that the glossary avoids: "Backup" (the screen is "Sync"), "Combined Balance" (net)

Deferred to their own ticket: Accounts and Cash Books.

## Consequences

### Positive

- Every built screen does something real.

### Negative

- The design file no longer matches the app one to one; this ADR is the list of differences beyond ADR 0006.
