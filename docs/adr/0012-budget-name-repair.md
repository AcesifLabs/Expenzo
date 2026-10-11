# ADR 0012: Repairing budget names the server dropped

## Status

Accepted

## Context

Until SAAP-59 the backend `budgets` table had no `name` column, so every name the app pushed was dropped. The migration fills existing rows with "Unnamed budget". A pull that returns that default would overwrite the real name still on the phone, and a new phone would never see the real name.

Pushing names back through the normal sync queue is unsafe: queued rows are full snapshots that can overwrite newer edits from another device, and an update for a budget deleted elsewhere re-creates it.

## Decision

- `POST /budgets/names` takes `{id, name}` pairs and, in one statement, sets the name only on the caller's rows whose name is still "Unnamed budget". It never creates rows and touches no other column, `updatedAt` included.
- Not bumping `updatedAt` means the repair can never win a conflict against a real edit. The cost: a second phone that only ever saw "Unnamed budget" gets the real name on its next full pull or the next edit of that budget.
- Each phone runs the repair after a sync cycle until the server accepts every batch (1000 names per request; names over 100 characters are skipped). Until then, a pulled default name does not replace a real local name.
- "Unnamed budget" means "no name" to sync. On update the server drops a name that is blank or the default, so a device that only ever saw the default cannot overwrite a repaired name. The budget form refuses it as a name, and the app shows it as a translated "Unnamed budget" label.

The same fill-only pattern restores `records.budgetId`, which the server also dropped (SAAP-76): `POST /records/budget-links` sets it only where the server has null, never creates rows and leaves `updatedAt` alone.

## Consequences

### Positive

- No device can lose an edit or resurrect a deleted budget because of the repair.

### Negative

- Secondary devices may show "Unnamed budget" for old budgets until a full pull or an edit.
- The placeholder text is reserved and cannot be used as a real name.
