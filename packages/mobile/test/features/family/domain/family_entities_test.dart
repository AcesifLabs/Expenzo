import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/family/data/models/family_json.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/group_summary.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/factories/family_factory.dart';

void main() {
  group('GroupRole.fromApi', () {
    test('reads the three roles', () {
      expect(GroupRole.fromApi('admin'), GroupRole.admin);
      expect(GroupRole.fromApi('member'), GroupRole.member);
      expect(GroupRole.fromApi('viewer'), GroupRole.viewer);
    });

    test('reads an unknown role as viewer, the least access', () {
      expect(GroupRole.fromApi('owner'), GroupRole.viewer);
      expect(GroupRole.fromApi(null), GroupRole.viewer);
    });

    test(
      'lets admins and members assign shared budgets, only admins share',
      () {
        expect(GroupRole.member.canAssignSharedBudget, isTrue);
        expect(GroupRole.viewer.canAssignSharedBudget, isFalse);
        expect(GroupRole.admin.canShareBudget, isTrue);
        expect(GroupRole.member.canShareBudget, isFalse);
      },
    );
  });

  group('MyGroup.ownsBudget', () {
    final group = makeMyGroup();

    test('is true for a listed budget I own', () {
      expect(group.ownsBudget('bud-1'), isTrue);
    });

    test('is false for a listed budget someone else owns', () {
      expect(makeMyGroup(myUserId: 'user-2').ownsBudget('bud-1'), isFalse);
    });

    test('is false for an unlisted budget', () {
      expect(group.ownsBudget('bud-9'), isFalse);
      expect(group.listsBudget('bud-9'), isFalse);
    });
  });

  test('InviteCode.isExpiredAt counts the exact expiry as expired', () {
    final invite = InviteCode(
      code: 'RF4XK2',
      expiresAt: DateTime.utc(2026, 3, 3, 10),
    );

    expect(invite.isExpiredAt(DateTime.utc(2026, 3, 3, 9, 59)), isFalse);
    expect(invite.isExpiredAt(DateTime.utc(2026, 3, 3, 10)), isTrue);
    expect(invite.isExpiredAt(DateTime.utc(2026, 3, 3, 11)), isTrue);
  });

  test('SharedBudgetProgress.ratio is 0 when nothing is planned', () {
    final progress = SharedBudgetProgress(
      id: 'b',
      name: 'b',
      period: BudgetPeriod.monthly,
      amount: 0,
      effectiveAmount: 0,
      spent: 50,
      periodStart: DateTime.utc(2026),
      periodEnd: DateTime.utc(2026, 2),
    );

    expect(progress.ratio, 0);
  });

  group('JSON', () {
    test('parses /groups/me and round trips through toJson', () {
      final parsed = myGroupFromJson(myGroupJson())!;

      expect(parsed.group.monthlyBudget, 50000.0);
      expect(parsed.myRole, GroupRole.admin);
      expect(parsed.members.map((m) => m.userId), ['user-1', 'user-2']);
      expect(parsed.invite?.code, 'RF4XK2');
      expect(myGroupFromJson(myGroupToJson(parsed)), parsed);
    });

    test('reads a null group as not in a group', () {
      expect(myGroupFromJson({'group': null, 'me': null}), isNull);
    });

    test('parses the summary with numbers and round trips', () {
      final summary = groupSummaryFromJson(groupSummaryJson());

      expect(summary.spent, 120.5);
      expect(summary.planned, 1000.0);
      expect(summary.sharedBudgets.single.periodStart, DateTime.utc(2026, 4));
      expect(groupSummaryFromJson(groupSummaryToJson(summary)), summary);
    });

    test('the summary has no income figure', () {
      final json = groupSummaryToJson(groupSummaryFromJson(groupSummaryJson()));

      expect(json.toString().toLowerCase(), isNot(contains('income')));
    });
  });
}
