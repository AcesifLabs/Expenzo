# SAAP-54 — Decisions

## D1 — Edit record budget UI

**Choice:** Add budget dropdown on `RecordFormPage` for `RecordType.expense`, matching new transaction sheet (name · period, “No budget”, disabled when loading/empty).

**Rationale:** Design mandates optional budget on expenses; edit path is primary for EX-50 revamp. Full `AllBudgetsPicker` route not required for parity with create sheet.

## D2 — Preserve record metadata on edit save

**Choice:** Keep `_loadedRecord` and pass through `source`, `sourceId`, `createdAt` when saving edits loaded by id.

**Rationale:** Avoid regressing scanned/synced records when fixing `budgetId`; pre-existing save always forced `ExpenseSource.manual`.

## D3 — AllBudgetsPicker

**Choice:** Defer dedicated picker route; dropdown sufficient for SAAP-54.

**Rationale:** No router module exists; category picker pattern not required by linking design doc (dropdown specified for new transaction sheet).

## D4 — Loop artifacts only under `.cursor/loop/SAAP-54/`

**Choice:** Document ticket/context/decision/report locally; do not push.
