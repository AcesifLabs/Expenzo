# Domain Glossary

## Budget

A named spending limit defined by the user. A budget has an amount, a period (weekly, monthly, yearly), and an optional rollover setting. It is no longer tied to a specific expense category.

## Budget Name

The user-provided label for a budget, displayed in lists, details, and the dashboard. Stored as a required string on the `Budget` entity.

## Budget Period

The time window over which a budget's spending is evaluated. One of: `weekly`, `monthly`, `yearly`.

## Budget Progress

A read-only summary of how much of a budget has been spent in the current period, expressed as an amount and a percentage.

## Rollover

A budget setting that allows unspent funds from a previous period to be added to the current period's effective budget amount.

## Create Budget Screen

The screen where a user creates a new budget by entering a name, amount, period, and rollover preference.

## Budget Details Screen

The screen that shows a single budget's progress and the list of transactions that contributed to that progress.

## Receipt Scan

Capturing or selecting a photo of a paper or digital receipt so the app can propose values for a new expense Record. It is a form-prefill aid, not a separate Record source and not a stored document.

_Avoid_: OCR scan, receipt import, receipt upload

## Receipt Extraction

The structured result of reading a receipt image: a total amount, a short generalized transaction description, an optional transaction date, and an optional expense category name. Applied to the New Transaction sheet for the user to confirm before saving.

_Avoid_: parsed receipt, receipt OCR result, receipt title

## Receipt Scan Camera

The full-screen camera experience used to align, capture, or pick a receipt image for Receipt Extraction.

## Net

Income minus expense for the selected date range (for example "Net this month"). Shown with a + or − sign. There are no accounts or opening balances, so the app never calls this a balance.

_Avoid_: balance, total balance

## Currency

The single ISO 4217 currency (for example BDT, USD) the user picks in Settings. Every amount in the app is formatted from it by one formatter. Records do not carry their own currency.

_Avoid_: currency symbol (as the setting), multi-currency

## Brand Color

Mint. Used for primary actions, the selected tab, the add button, the avatar and interactive states (focus, selection, switches, links), in both light and dark mode.

## Accent Color

Lavender. Used for secondary emphasis: chart highlights, tags, info tiles. Interactive states (focus, selection, switches, links) use the Brand Color.

## Record

One money movement the user logged: an amount, a direction (Income / Expense), a date, a category and optionally one Budget. Created by hand, from Auto-import, from a Receipt Scan or by a recurring item.

_UI label_: transaction
_Avoid_: entry, expense (for the record itself)

## Sync

The continuous two-way copy of a signed-in user's Records, Budgets, categories, recurring items and Goals to their account, so another device gets the same data. Not a snapshot: there is nothing to restore from. The user can turn it off on the device; changes then queue until it is on again. Deleting data on one device does not delete it on the others.

_Avoid_: backup, restore

## Export

A one-off CSV copy of the user's Records, Budgets and categories, handed to another app through the share sheet. Not Sync and not a backup: nothing reads it back into Expenzo.

_Avoid_: backup, download

## Income / Expense

The direction of money on a Record. Income is shown in teal with a "+" sign, expense in rose with a "−" sign. Color is never the only signal.

## Auto-import

Everything that turns SMS messages into Records: SMS permission, choosing senders, scanning past messages, SMS formats and matching rules. Lives under Settings.

_Avoid_: Scan (as a tab or feature name), SMS scan

## SMS Format

A learned pattern for one sender's messages (trigger word plus amount position) used to create Records from future SMS. Stored as an expense template.

_Avoid_: template (in user-facing text)

## Matching Rule

A user-defined pattern (regular expression) that extracts transactions from SMS when no SMS Format applies. Stored as a parsing rule.

_Avoid_: parsing rule (in user-facing text)

## Transaction Sheet

The keypad bottom sheet used both to add and to edit a Record. It is the only Record editor.

_Avoid_: record form, edit expense screen

## Budget Alert

A notification sent once when a budget reaches 80% of its effective amount and once when it goes over, per budget period. Each level has its own switch under Settings → Notifications, below the master "Allow notifications" switch.

## App Language

The language the UI renders in: Match device (the phone's language, English if it isn't supported), English or বাংলা. Picked in Settings and stored as `languageCode` ('system', 'en', 'bn'). Amounts and dates keep Latin digits in every language.

_Avoid_: locale (in user-facing text)

## Untouched Default Category

A seeded category (id starting with `default_`) whose name still equals its English seed name. Only these are shown translated; once renamed, the user's text is shown as typed. Stored names stay English.

## Failure Message

The localized text a user sees for a `Failure`, from `failureText()`. Not `Failure.message`, which is diagnostic text for logs.

## Goal

A savings target the user sets: a name, a target amount, and optionally a target date and monthly contribution. Progress is the saved amount the user records by hand; it is never derived from Records or Budgets (ADR 0009).

_Avoid_: savings budget, wishlist item

## Goal Contribution

An amount the user adds to a Goal's saved amount from the dashboard goal card. It updates the Goal only and creates no Record.

## Onboarding

The one-time, skippable setup shown on first launch: income, recurring payments, a suggested 50/30/20 budget plan, a savings Goal and a short tutorial. It writes real settings, recurring transactions, budgets and a Goal.

## Display Preferences

Device-local choices: theme, currency, number format, font size, first day of week, home page, notification toggles, recurring defaults and the Sync switch. Stored on the device only, never synced (ADR 0010). Delete all data resets them, except that Onboarding is not shown again.

## Family Group

A shared space created by a signed-in user; each user belongs to at most one. It has a name, one Currency (the creator's) and up to 10 members (Admin included), each with a Group Role.

_Avoid_: household, team

## Group Role

A member's permission level in a Family Group: Admin (manage members, invites and Shared Budgets), Member (add Records to Shared Budgets) or Viewer (read only).

## Shared Budget

A Budget marked with a Family Group's id. Only an Admin can share a Budget into the group; its owner can always unshare it, even after losing the Admin role. Members see it read-only; its progress counts Records from current members assigned to it and comes from the server, not local data (ADR 0008). Family totals and spending by member count only Records linked to Shared Budgets; a member's other Records stay private.

## Invite Code

A 6-character code (A–Z, 2–9, no lookalikes) that lets a signed-in user join a Family Group. Valid for 48 hours, reusable until it expires; regenerating it voids the previous code.
