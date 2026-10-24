import { getMetadataArgsStorage, QueryRunner } from 'typeorm';
import { Group } from './group.entity';
import { GroupMember } from './group-member.entity';
import { GroupInvite } from './group-invite.entity';
import { AddGroups1792854426416 } from '../../migrations/1792854426416-AddGroups';

const storage = () => getMetadataArgsStorage();
const column = (target: object, name: string) =>
  storage().columns.find((c) => c.target === target && c.propertyName === name);
const relation = (target: object, name: string) =>
  storage().relations.find((r) => r.target === target && r.propertyName === name);

describe('Group entities', () => {
  it('should allow one group per user with a unique index on group_members.userId', () => {
    const index = storage().indices.find(
      (i) => i.target === GroupMember && JSON.stringify(i.columns) === JSON.stringify(['userId']),
    );

    expect(index?.unique).toBe(true);
  });

  it('should key GroupMember by groupId and userId', () => {
    const primary = storage()
      .columns.filter((c) => c.target === GroupMember && c.options.primary)
      .map((c) => c.propertyName);

    expect(primary).toEqual(['groupId', 'userId']);
  });

  it('should store member userId as text like users.id', () => {
    expect(column(GroupMember, 'userId')?.options.type).toBe('text');
  });

  it('should keep the group when its creator is deleted', () => {
    expect(relation(Group, 'creator')?.options.onDelete).toBe('SET NULL');
    expect(column(Group, 'createdBy')?.options.nullable).toBe(true);
  });

  it('should make GroupInvite.code a 6-character primary column', () => {
    const code = column(GroupInvite, 'code');

    expect(code?.options.primary).toBe(true);
    expect(code?.options).toEqual(expect.objectContaining({ type: 'char', length: 6 }));
  });
});

// Kept out of src/migrations: the TypeORM CLI loads every file there as a migration.
describe('AddGroups migration', () => {
  const run = async (step: 'up' | 'down') => {
    const query = jest.fn();
    await new AddGroups1792854426416()[step]({ query } as unknown as QueryRunner);
    return query.mock.calls.map(([sql]: [string]) => sql);
  };

  it('should create the three tables and the role check', async () => {
    const sql = (await run('up')).join('\n');

    for (const table of ['groups', 'group_members', 'group_invites']) {
      expect(sql).toContain(`CREATE TABLE "${table}"`);
    }
    expect(sql).toContain(`CHECK ("role" IN ('admin', 'member', 'viewer'))`);
    expect(sql).toMatch(/CREATE UNIQUE INDEX "[^"]+" ON "group_members" \("userId"\)/);
  });

  it('should not depend on a uuid extension', async () => {
    expect((await run('up')).join('\n')).not.toContain('uuid_generate_v4');
  });

  it('should drop group_invites, group_members, groups in that order', async () => {
    const drops = (await run('down')).filter((sql) => sql.startsWith('DROP TABLE'));

    expect(drops).toEqual(['DROP TABLE "group_invites"', 'DROP TABLE "group_members"', 'DROP TABLE "groups"']);
  });
});
