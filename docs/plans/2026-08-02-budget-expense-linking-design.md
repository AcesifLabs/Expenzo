# Budget–Expense Linking — Design

Date: 2026-08-02
Branch: feat/EX-55
Status: Approved (brainstormed & validated)

## Context

The reviewed diff on `feat/EX-55` decoupled budgets from expense categories
(`Budget.categoryId` → `Budget.name`) and left budget spend computed **globally**
(`getTotalSpending(start, end)` over ALL expenses in a period). Code review flagged this as
a correctness regression: multiple budgets whose periods overlap reported identical spend.

The product decision is to **re-link budgets to expenses explicitly** — not via category, but
via a user-chosen budget on each expense, selected from a new dropdown in the New Transaction
Sheet. This design covers that feature and folds in the review's mechanical fixes (migration,
period-boundary, N+1, file organization) that touch the same code.

## Decisions (from brainstorming)

1. **Link model:** Optional, single budget per expense (`record.budgetId`, nullable). Not
   many-to-many; not mandatory.
2. **Dropdown options:** All enabled budgets, shown as `name` with period subtitle
   (e.g. "Groceries · Monthly"). No category constraint — any expense may link to any budget.
   No date-reactive filtering.
3. **Spend model:** Strict per-budget. A budget counts only expenses explicitly linked to it
   (`budgetId == budget.id`) within its current period. No backfill; pre-existing expenses are
   unlinked and count toward no budget.
4. **Budget delete:** Unlink — set `budgetId = NULL` on affected records, keep the records.
5. **Sync:** Unlinked records flow through the sync queue as normal record mutations; `budgetId`
   is a synced field on records.
6. **Edit recompute:** None needed — spend is computed live on read. Alert re-triggering is
   deferred (`CheckBudgetAlerts` is currently dead code / unwired; wiring it is out of scope).

## Data Model

### `records` table (add)
```dart
TextColumn get budgetId => text().nullable()();
// index: idx_records_budget_id on {#budgetId}
```
`Record` entity, Drift companion, record model/mappers, and the **record sync payload** all
gain `budgetId`.

### `budgets` table (already changed in diff, kept)
`categoryId` (nullable) → `name` (NOT NULL). `idx_budgets_category_id` removed.

### Migration V16 (schemaVersion 15 → 16), one coordinated step
1. Rebuild `budgets` (table-rebuild idiom, mirroring `_migrateV12`): drop `category_id`, add
   NOT NULL `name`. **No backfill** — legacy rows get `name = ''` (empty), which satisfies the
   NOT NULL constraint without inventing data.
2. `ALTER TABLE records ADD COLUMN budget_id TEXT;` (nullable → existing rows unlinked).
3. Create `idx_records_budget_id`.
4. Remove the stale `CREATE INDEX ... idx_budgets_category_id ON budgets (category_id)` line
   from `_migrateV15` (it references a now-removed column).

Ordering: `_migrateV15` runs for `from < 15`, `_migrateV16` for `from < 16`. `_migrateV16`
must be self-sufficient and not depend on the stale index.

## UI & Create Flow

New Transaction Sheet (`new_transaction_sheet.dart`, currently create-only via `AddRecord`):
- New dropdown **below the category selector**, visible only when `_type == expense`. Hidden +
  cleared when type is income.
- Options: enabled budgets, `name` + period subtitle. Loaded via budget repository on sheet open.
- Default = unselected ("No budget") → `budgetId = null`. Logging must never require a budget.
- Empty/loading budgets → disabled "No budgets yet" state; never blocks the sheet.
- On submit, `Record` includes `budgetId: _selectedBudgetId`; `AddRecord` unchanged otherwise.
- Receipt Scan does NOT propose a budget; the field stays at default after a scan.
- Styling matches the existing category selector (same tokens/spacing). No widget test.

## Spend Queries, Delete & Sync

- New scoped method `getBudgetSpending(budgetId, start, end)`:
  `WHERE budget_id = ? AND date >= ? AND date < ? AND record_type = expense`, aggregated with
  SQL `SUM(amount)` (null → 0.0). Half-open `[start, end)` is the period-boundary fix built in.
- `GetBudgetsWithProgress` / `GetBudgetProgress` call it with each budget's own `id`. N+1
  dissolves: one scoped query per distinct budget id is inherent and correct; no memoization.
- Old global `getTotalSpending(start, end)` removed **iff** orphaned (verify at implementation;
  delete surgically only if no other feature uses it).
- `GetBudgetTransactions` → expenses where `budgetId == budget.id` in-period, same half-open bound.
- Budget delete use case, one transaction: SELECT affected record ids → `UPDATE records SET
  budget_id = NULL WHERE budget_id = ?` → delete budget → enqueue record sync updates for each
  affected id + the budget-delete sync.

## Testing (TDD, mocktail, factories)

- `getBudgetSpending`: boundary (start included / end excluded), budgetId scoping, expense-only,
  SUM=0 when none.
- `GetBudgetProgress`: percentage, rollover, `isOverBudget` strict-`>`, zero-effective guard, Left.
- `GetBudgetsWithProgress`: two distinctly-linked budgets report distinct spend (locks the fix).
- `GetBudgetTransactions`: only this budget's linked expenses in-period.
- `CheckBudgetAlerts`: ≥80% fires, <80% doesn't, rollover raises denominator, Left paths
  (kept though dormant).
- Budget delete: records unlinked, budget removed, affected ids enqueued for sync.
- Migration V16: `records` has `budget_id`; `budgets` has `name`, no `category_id`;
  `idx_budgets_category_id` gone.
- No frontend widget tests (repo rule).

## File Organization

- Extract `BudgetProgress` → `domain/entities/budget_progress.dart` (in scope).
- Move `budget_ui_tokens.dart` → `presentation/constants/budget_ui_tokens.dart`.
- Move `budgetProgressColor` out of `widgets/` → `*.helpers.dart`.
- Add `textTertiary` (`0xFFCCCCCC`) token; replace hardcoded colors in `budget_list_page`,
  `budget_progress_card`; route shared `budget_transaction_list` to `AppColors`/theme (no
  feature-token import from `shared/`).
- Remove stray double blank line in `dashboard_page.dart`.

## Deferred (out of scope)

- Wiring `CheckBudgetAlerts` to a trigger (create/edit/scan). File as a follow-up.

## Review findings resolved by this design

| Finding | Resolution |
|---|---|
| P0 missing migration | Migration V16 (records `budget_id` + budgets `name`) |
| P0 stale category index | Removed in `_migrateV15` |
| P1 global/overlapping spend | Dissolved — spend is per-budget by construction |
| P1 period-boundary double-count | Half-open `[start, end)` in scoped query |
| P1 missing use-case tests | Added for GetBudgetProgress + CheckBudgetAlerts |
| P2 N+1 + Dart-side sum | SQL SUM + inherent per-budget scoping |
| P2 hardcoded colors | Consolidated onto tokens / theme |
| P2 helper-in-widgets, tokens-at-root, type-in-usecase, blank line | File-org task |
