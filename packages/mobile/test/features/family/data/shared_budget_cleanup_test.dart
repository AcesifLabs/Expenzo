import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/family/data/services/shared_budget_cleanup.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/factories/family_factory.dart';
import '../../../support/shared_budget_rows.dart';

void main() {
  late AppDatabase db;
  late SharedBudgetCleanup cleanup;

  const mineRef = SharedBudgetRef(id: 'mine', name: 'Mine', ownerId: 'user-2');
  const adminsRef = SharedBudgetRef(
    id: 'admins',
    name: 'Rent',
    ownerId: 'user-1',
  );
  MyGroup group({
    List<SharedBudgetRef> budgets = const [mineRef, adminsRef],
    GroupRole role = GroupRole.member,
    String id = 'group-1',
  }) => makeMyGroup(
    myUserId: 'user-2',
    myRole: role,
    sharedBudgets: budgets,
    groupId: id,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cleanup = SharedBudgetCleanup(
      budgetDao: db.budgetDao,
      syncQueueDao: db.syncQueueDao,
    );
  });
  tearDown(() => db.close());

  test(
    'out of any group: others shared budgets go, mine become personal',
    () async {
      await insertBudgetRow(db, 'mine', groupId: 'group-1');
      await insertBudgetRow(db, 'admins', groupId: 'group-1');

      await cleanup.apply(previous: group(), current: null);

      expect(await budgetGroupIds(db), {'mine': null});
    },
  );

  test('in another group: the old group budgets go', () async {
    await insertBudgetRow(db, 'admins', groupId: 'group-1');

    await cleanup.apply(
      previous: group(),
      current: group(id: 'group-2', budgets: const []),
    );

    expect(await budgetGroupIds(db), isEmpty);
  });

  test('same group: an unlisted budget someone else owned goes', () async {
    await insertBudgetRow(db, 'admins', groupId: 'group-1');

    await cleanup.apply(
      previous: group(),
      current: group(budgets: const [mineRef]),
    );

    expect(await budgetGroupIds(db), isEmpty);
  });

  test('same group: my unlisted budget stays', () async {
    await insertBudgetRow(db, 'mine', groupId: 'group-1');

    await cleanup.apply(
      previous: group(),
      current: group(budgets: const []),
    );

    expect(await budgetGroupIds(db), {'mine': 'group-1'});
  });

  test(
    'same group: an admin keeps a budget just shared on this phone',
    () async {
      await insertBudgetRow(db, 'fresh', groupId: 'group-1');

      await cleanup.apply(
        previous: null,
        current: group(role: GroupRole.admin),
      );

      expect(await budgetGroupIds(db), {'fresh': 'group-1'});
    },
  );

  test('a budget with a pending change is left alone', () async {
    await insertBudgetRow(db, 'admins', groupId: 'group-1');
    await db.syncQueueDao.enqueue(
      tableName: 'budgets',
      recordId: 'admins',
      action: 'update',
      payload: '{}',
    );

    await cleanup.apply(previous: group(), current: null);

    expect(await budgetGroupIds(db), {'admins': 'group-1'});
  });

  test('personal budgets are never touched and nothing is queued', () async {
    await insertBudgetRow(db, 'personal');
    await insertBudgetRow(db, 'admins', groupId: 'group-1');

    await cleanup.apply(previous: group(), current: null);

    expect(await budgetGroupIds(db), {'personal': null});
    expect(await db.syncQueueDao.getUnsyncedCount(), 0);
  });
}
