# ADR 0004: One bottom sheet for adding and editing Records

## Status

Accepted

## Context

New Records used a keypad bottom sheet with type, budget, recurring and receipt scan. Editing used a separate full-page form without budget or recurring fields, and it dropped the Record's `budgetId` and `source` on save.

## Decision

The Transaction Sheet (`NewTransactionSheet`) handles both create and edit. Edit mode pre-fills every field, preserves `source`, `sourceId` and `budgetId`, and offers Delete. Both paths dispatch through `RecordBloc`. `RecordFormPage` and its routes are removed.

## Consequences

### Positive

- One mental model and one code path; no silent data loss on edit.

### Negative

- The sheet grows to cover edit mode; sub-widgets under `new_transaction/` should absorb that.
- Deep links to `/records/:id/edit` stop existing.
