# ADR 0008: Family data comes from server endpoints, not the sync engine

## Status

Accepted

## Context

Sync is per user: every row carries a `userId` and `/sync/pull` filters by it. A Family Group needs members to see shared spending. Pulling other members' Records into local Drift would touch the sync engine, conflict handling and offline edits.

## Decision

- Shared Budgets are owned by an Admin (`userId` = admin) and carry `groupId`. Pull returns them to members read-only.
- Records stay with their creator and never sync to other members.
- The Family dashboard and Shared Budget progress come from live endpoints (`GET /groups/me`, `GET /groups/:id/summary`). The phone caches the last response and shows "last updated" when offline.
- Totals count only current members. When a member leaves, their Records stop counting; when a group is deleted, its Shared Budgets become personal budgets of their owner (`groupId` set to null).
- Pull has no tombstones, so after each `/groups/me` fetch the phone drops local budgets whose `groupId` is not its current group.

## Consequences

### Positive

- The sync engine and conflict model stay unchanged.
- Personal Records stay private by construction.

### Negative

- Family views need a connection for fresh numbers.
- Shared Budget progress on a member's phone differs from local budget maths.
