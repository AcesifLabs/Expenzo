import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/factories/budget_factory.dart';
import '../../../support/factories/family_factory.dart';

void main() {
  const adminsRef = SharedBudgetRef(
    id: 'bud-1',
    name: 'Groceries',
    ownerId: 'user-1',
  );
  const mineRef = SharedBudgetRef(id: 'bud-2', name: 'Fuel', ownerId: 'user-2');
  BudgetAccess as(GroupRole role) => BudgetAccess(
    currentGroup: () => makeMyGroup(
      myUserId: 'user-2',
      myRole: role,
      sharedBudgets: const [adminsRef, mineRef],
    ),
  );
  final personal = makeBudget(id: 'own');
  final admins = makeBudget(id: 'bud-1', groupId: 'group-1');
  final mine = makeBudget(id: 'bud-2', groupId: 'group-1');

  test('a personal budget is editable and assignable for everyone', () {
    for (final role in GroupRole.values) {
      expect(as(role).canEdit(personal), isTrue);
      expect(as(role).canAssignTo(null), isTrue);
    }
    expect(BudgetAccess.none().canEdit(personal), isTrue);
  });

  test(
    'the owner edits their shared budget, a member cannot edit the admins',
    () {
      expect(as(GroupRole.member).canEdit(mine), isTrue);
      expect(as(GroupRole.member).canEdit(admins), isFalse);
    },
  );

  test('a demoted owner can still edit and unshare their shared budget', () {
    expect(as(GroupRole.viewer).canEdit(mine), isTrue);
    expect(as(GroupRole.viewer).canUnshare(mine), isTrue);
    expect(as(GroupRole.viewer).canUnshare(personal), isFalse);
  });

  test(
    'an admin edits an unlisted budget of their group, not another admins listed one',
    () {
      final fresh = makeBudget(id: 'new', groupId: 'group-1');

      expect(as(GroupRole.admin).canEdit(fresh), isTrue);
      expect(as(GroupRole.admin).canEdit(admins), isFalse);
    },
  );

  test('members assign shared budgets, viewers do not', () {
    expect(as(GroupRole.member).canAssignTo('group-1'), isTrue);
    expect(as(GroupRole.admin).canAssignTo('group-1'), isTrue);
    expect(as(GroupRole.viewer).canAssignTo('group-1'), isFalse);
    expect(as(GroupRole.viewer).assignable([personal, admins]), [personal]);
  });

  test('a budget of another group is not assignable', () {
    expect(as(GroupRole.member).canAssignTo('group-9'), isFalse);
  });

  test(
    'with no cached group a shared budget is neither editable nor assignable',
    () {
      final access = BudgetAccess.none();

      expect(access.canEdit(admins), isFalse);
      expect(access.canAssignTo('group-1'), isFalse);
    },
  );

  group('canShare', () {
    test('an admin shares a new budget and their own', () {
      expect(as(GroupRole.admin).canShare(null), isTrue);
      expect(as(GroupRole.admin).canShare(personal), isTrue);
    });

    test('members, viewers and users without a group do not', () {
      expect(as(GroupRole.member).canShare(personal), isFalse);
      expect(as(GroupRole.viewer).canShare(null), isFalse);
      expect(BudgetAccess.none().canShare(null), isFalse);
    });

    test('an admin cannot share another admins budget', () {
      expect(as(GroupRole.admin).canShare(admins), isFalse);
    });

    test('names the current group', () {
      expect(as(GroupRole.admin).currentGroupId, 'group-1');
      expect(as(GroupRole.admin).currentGroupName, 'Rahman Family');
    });
  });
}
