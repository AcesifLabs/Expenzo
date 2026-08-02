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
