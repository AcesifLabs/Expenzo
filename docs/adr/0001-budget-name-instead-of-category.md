# ADR 0001: Replace `Budget.categoryId` with `Budget.name`

## Status

Accepted

## Context

The budget feature is being revamped to match the new design in `packages/mobile/design/expenzo.pen`. The new `CreateBudgetScreen` introduces a **"Budget Name"** field, and the existing domain model stores budgets against a `categoryId`. There are no existing budgets in production, so a breaking schema change is acceptable.

We need to decide how a budget is identified and displayed in the UI.

## Decision

Remove `categoryId` from the `Budget` entity and replace it with a required `name` field. A budget is now an independent, named spending limit and is no longer tied to a specific expense category.

## Consequences

### Positive

- Simpler domain model: budgets are no longer coupled to the category taxonomy.
- Matches the new design exactly: users enter a free-text budget name.
- Reduces complexity in spending calculations; all budgets now track total spending within a period.

### Negative

- Breaks existing budget-related code, tests, factories, and sync payloads.
- Removes the ability to scope a budget to a single category. If category-scoped budgets are needed later, a new field or relationship must be introduced.

## Implementation Notes

- Update `Budget` entity, `BudgetsTable`, `BudgetDao`, `BudgetLocalDatasource`, `BudgetRepositoryImpl`, and `BudgetsSyncHandler`.
- Update `BudgetProgress` to carry `name` instead of `categoryId`.
- Update all presentation pages and dashboard widgets that reference `categoryId`.
- Update test factories and mocks.
- Because there are no existing budgets, no data migration is required.
