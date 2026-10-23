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
      expect({ entity, onDelete: relation.options.onDelete }).toEqual({ entity, onDelete: 'CASCADE' });
    }
  });
});
