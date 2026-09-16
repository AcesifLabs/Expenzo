# SAAP-54 — Budget screens & expense linking

- **Jira:** [SAAP-54](https://acesif.atlassian.net/browse/SAAP-54) (API fetch blocked; scope from design + pen)
- **Branch:** `feat/SAAP-54-budget-screens`
- **Status:** In progress → verify & close gaps

## Goal

Deliver budget UI aligned with pen frames and **budget–expense linking** per
`docs/plans/2026-08-02-budget-expense-linking-design.md`.

## Pen frames (source of truth for UI)

| Frame | Implementation |
|-------|----------------|
| `BudgetsScreen` | `budget_list_page.dart` |
| `CreateBudgetScreen` | `budget_form_page.dart` (create) |
| `BudgetDetailsScreen` | `budget_details_page.dart` |
| `AllBudgetsPicker` | Inline budget dropdown on transaction flows (full-screen picker deferred) |

## Acceptance (from design)

- Named budgets (`name`), optional `record.budgetId` on expenses
- Per-budget spend via `getBudgetSpending(budgetId, …)` half-open period
- New transaction sheet: budget dropdown for expenses only
- Edit expense: user can view/change budget link
- Budget delete unlinks records; sync carries `budgetId`
- Migration V16 + unit tests for use cases and DAO

## Out of scope

- Wiring `CheckBudgetAlerts` to live triggers
- Widget tests for budget UI
