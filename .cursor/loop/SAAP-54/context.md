# SAAP-54 — Context

## Product (CONTEXT.md)

- **Budget:** named limit with amount, period, optional rollover — not tied to category.
- **Create Budget Screen / Budget Details Screen:** glossary terms for form and detail views.

## Technical baseline (develop @ 141dc7f)

Most of EX-55 / budget-expense linking is already on `develop`:

- Schema: `records.budget_id`, `budgets.name`, migration V16 tests
- Domain/data: `getBudgetSpending`, progress use cases, delete-unlink, sync payload
- UI: budget list/form/details revamp; new transaction sheet budget dropdown

## Gap identified this loop

- **Edit expense/income** (`record_form_page.dart`, route `/records/:id/edit`): did not load or save `budgetId`, so edits cleared links and users could not assign budgets from the edit screen (design requires link on create **and** edit flows).

## Jira

`.cursor/loop/jira-snapshot.json` returned empty issues (fallback); ticket text inferred from SAAP-54 branch name, design doc, and pen frames.
