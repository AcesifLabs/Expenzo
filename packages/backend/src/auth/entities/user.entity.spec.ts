import { readdirSync } from 'fs';
import { join } from 'path';
import { getMetadataArgsStorage } from 'typeorm';
import { User } from './user.entity';

const loadEntities = (dir: string) => {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) loadEntities(path);
    else if (entry.name.endsWith('.entity.ts')) require(path);
  }
};

// Shared rows that outlive the user who made them. A Family Group belongs to
// all its members; the leave rules run before the account goes (Task 7).
const KEPT_ON_DELETE = new Set(['Group.creator']);

// Deleting the user row (DELETE /auth/account) must take every synced row with it.
describe('User entity', () => {
  it('should cascade every relation to User on delete', () => {
    loadEntities(join(__dirname, '../..'));
    const toUser = getMetadataArgsStorage().relations.filter(
      (r) => typeof r.type === 'function' && (r.type as () => unknown)() === User,
    );

    expect(toUser.length).toBeGreaterThan(0);
    for (const relation of toUser) {
      const entity = (relation.target as { name: string }).name;
      if (KEPT_ON_DELETE.has(`${entity}.${relation.propertyName}`)) continue;
      expect({ entity, onDelete: relation.options.onDelete }).toEqual({ entity, onDelete: 'CASCADE' });
    }
  });

  it('should set kept rows to NULL instead of failing the delete', () => {
    loadEntities(join(__dirname, '../..'));
    const kept = getMetadataArgsStorage().relations.filter((r) =>
      KEPT_ON_DELETE.has(`${(r.target as { name: string }).name}.${r.propertyName}`),
    );

    expect(kept).toHaveLength(KEPT_ON_DELETE.size);
    for (const relation of kept) expect(relation.options.onDelete).toBe('SET NULL');
  });
});
