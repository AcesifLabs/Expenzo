import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/group_summary.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';

/// `GET /groups/me` body for a group with an Admin (me) and one Member.
Map<String, Object?> myGroupJson({
  String role = 'admin',
  String myUserId = 'user-1',
  Map<String, Object?>? invite = const {
    'code': 'RF4XK2',
    'expiresAt': '2026-03-03T10:00:00.000Z',
  },
}) => {
  'group': {
    'id': 'group-1',
    'name': 'Rahman Family',
    'currencyCode': 'BDT',
    'monthlyBudget': 50000,
    'createdAt': '2026-01-01T00:00:00.000Z',
  },
  'me': {'userId': myUserId, 'role': role},
  'members': [
    {
      'userId': 'user-1',
      'displayName': 'Karim',
      'photoUrl': null,
      'role': 'admin',
      'joinedAt': '2026-01-01T00:00:00.000Z',
    },
    {
      'userId': 'user-2',
      'displayName': null,
      'photoUrl': 'https://example.com/p.png',
      'role': 'member',
      'joinedAt': '2026-01-02T00:00:00.000Z',
    },
  ],
  'sharedBudgets': [
    {'id': 'bud-1', 'name': 'Groceries', 'ownerId': 'user-1'},
  ],
  'invite': invite,
};

/// `GET /groups/:id/summary` body matching [myGroupJson].
Map<String, Object?> groupSummaryJson() => {
  'groupId': 'group-1',
  'currencyCode': 'BDT',
  'monthlyBudget': 50000,
  'totals': {'spent': 120.5, 'planned': 1000, 'monthSpent': 120.5},
  'members': [
    {'userId': 'user-2', 'displayName': null, 'spent': 80},
    {'userId': 'user-1', 'displayName': 'Karim', 'spent': 40.5},
  ],
  'sharedBudgets': [
    {
      'id': 'bud-1',
      'name': 'Groceries',
      'period': 'monthly',
      'amount': 1000,
      'effectiveAmount': 1000,
      'spent': 120.5,
      'periodStart': '2026-04-01T00:00:00.000Z',
      'periodEnd': '2026-05-01T00:00:00.000Z',
    },
  ],
  'month': {
    'start': '2026-04-01T00:00:00.000Z',
    'end': '2026-05-01T00:00:00.000Z',
  },
  'generatedAt': '2026-04-15T12:00:00.000Z',
};

GroupMember makeGroupMember({
  String userId = 'user-1',
  String? displayName = 'Karim',
  GroupRole role = GroupRole.admin,
  DateTime? joinedAt,
}) => GroupMember(
  userId: userId,
  displayName: displayName,
  role: role,
  joinedAt: joinedAt ?? DateTime.utc(2026, 1, 1),
);

MyGroup makeMyGroup({
  GroupRole myRole = GroupRole.admin,
  String myUserId = 'user-1',
  List<GroupMember>? members,
  List<SharedBudgetRef>? sharedBudgets,
  InviteCode? invite,
  String groupId = 'group-1',
  String currencyCode = 'BDT',
}) => MyGroup(
  group: FamilyGroup(
    id: groupId,
    name: 'Rahman Family',
    currencyCode: currencyCode,
    monthlyBudget: 50000,
  ),
  myUserId: myUserId,
  myRole: myRole,
  members:
      members ??
      [
        makeGroupMember(),
        makeGroupMember(
          userId: 'user-2',
          displayName: null,
          role: GroupRole.member,
          joinedAt: DateTime.utc(2026, 1, 2),
        ),
      ],
  sharedBudgets:
      sharedBudgets ??
      const [
        SharedBudgetRef(id: 'bud-1', name: 'Groceries', ownerId: 'user-1'),
      ],
  invite: invite,
);

GroupSummary makeGroupSummary({
  double spent = 120.5,
  double planned = 1000,
  List<SharedBudgetProgress>? sharedBudgets,
  String currencyCode = 'BDT',
}) => GroupSummary(
  groupId: 'group-1',
  currencyCode: currencyCode,
  monthlyBudget: 50000,
  spent: spent,
  planned: planned,
  monthSpent: spent,
  members: const [
    MemberSpending(userId: 'user-2', spent: 80),
    MemberSpending(userId: 'user-1', displayName: 'Karim', spent: 40.5),
  ],
  sharedBudgets:
      sharedBudgets ??
      [
        SharedBudgetProgress(
          id: 'bud-1',
          name: 'Groceries',
          period: BudgetPeriod.monthly,
          amount: 1000,
          effectiveAmount: 1000,
          spent: spent,
          periodStart: DateTime.utc(2026, 4, 1),
          periodEnd: DateTime.utc(2026, 5, 1),
        ),
      ],
  generatedAt: DateTime.utc(2026, 4, 15, 12),
);
