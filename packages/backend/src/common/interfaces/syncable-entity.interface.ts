/**
 * Base entity interface for all TypeORM entities in the sync service.
 * Provides common fields that all entities must have.
 */
export interface SyncableEntity {
  id: string;
  userId: string;
  createdAt?: Date;
  updatedAt?: Date;
}
