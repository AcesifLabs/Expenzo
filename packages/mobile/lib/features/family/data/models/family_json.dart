import 'package:expense_tracker/core/constants/budget_period.dart';

import '../../domain/entities/group_role.dart';
import '../../domain/entities/group_summary.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/entities/my_group.dart';

typedef Json = Map<String, Object?>;

MyGroup? myGroupFromJson(Json json) {
  final group = json['group'];
  final me = json['me'];
  if (group is! Json || me is! Json) return null;

  return MyGroup(
    group: FamilyGroup(
      id: group['id'] as String,
      name: group['name'] as String,
      currencyCode: group['currencyCode'] as String,
      monthlyBudget: _doubleOrNull(group['monthlyBudget']),
    ),
    myUserId: me['userId'] as String,
    myRole: GroupRole.fromApi(me['role'] as String?),
    members: [for (final m in _list(json['members'])) _memberFromJson(m)],
    sharedBudgets: [
      for (final b in _list(json['sharedBudgets']))
        SharedBudgetRef(
          id: b['id'] as String,
          name: b['name'] as String,
          ownerId: b['ownerId'] as String,
        ),
    ],
    invite: json['invite'] is Json
        ? inviteFromJson(json['invite'] as Json)
        : null,
  );
}

Json myGroupToJson(MyGroup value) {
  return {
    'group': {
      'id': value.group.id,
      'name': value.group.name,
      'currencyCode': value.group.currencyCode,
      'monthlyBudget': value.group.monthlyBudget,
    },
    'me': {'userId': value.myUserId, 'role': value.myRole.apiValue},
    'members': [
      for (final m in value.members)
        {
          'userId': m.userId,
          'displayName': m.displayName,
          'photoUrl': m.photoUrl,
          'role': m.role.apiValue,
          'joinedAt': m.joinedAt.toUtc().toIso8601String(),
        },
    ],
    'sharedBudgets': [
      for (final b in value.sharedBudgets)
        {'id': b.id, 'name': b.name, 'ownerId': b.ownerId},
    ],
    'invite': switch (value.invite) {
      final invite? => inviteToJson(invite),
      null => null,
    },
  };
}

InviteCode inviteFromJson(Json json) => InviteCode(
  code: json['code'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Json inviteToJson(InviteCode invite) => {
  'code': invite.code,
  'expiresAt': invite.expiresAt.toUtc().toIso8601String(),
};

GroupSummary groupSummaryFromJson(Json json) {
  final totals = json['totals'] as Json;

  return GroupSummary(
    groupId: json['groupId'] as String,
    currencyCode: json['currencyCode'] as String,
    monthlyBudget: _doubleOrNull(json['monthlyBudget']),
    spent: _double(totals['spent']),
    planned: _double(totals['planned']),
    monthSpent: _double(totals['monthSpent']),
    members: [
      for (final m in _list(json['members']))
        MemberSpending(
          userId: m['userId'] as String,
          displayName: m['displayName'] as String?,
          spent: _double(m['spent']),
        ),
    ],
    sharedBudgets: [
      for (final b in _list(json['sharedBudgets'])) _budgetFromJson(b),
    ],
    generatedAt: DateTime.parse(json['generatedAt'] as String),
  );
}

Json groupSummaryToJson(GroupSummary summary) => {
  'groupId': summary.groupId,
  'currencyCode': summary.currencyCode,
  'monthlyBudget': summary.monthlyBudget,
  'totals': {
    'spent': summary.spent,
    'planned': summary.planned,
    'monthSpent': summary.monthSpent,
  },
  'members': [
    for (final m in summary.members)
      {'userId': m.userId, 'displayName': m.displayName, 'spent': m.spent},
  ],
  'sharedBudgets': [
    for (final b in summary.sharedBudgets)
      {
        'id': b.id,
        'name': b.name,
        'period': b.period.name,
        'amount': b.amount,
        'effectiveAmount': b.effectiveAmount,
        'spent': b.spent,
        'periodStart': b.periodStart.toUtc().toIso8601String(),
        'periodEnd': b.periodEnd.toUtc().toIso8601String(),
      },
  ],
  'generatedAt': summary.generatedAt.toUtc().toIso8601String(),
};

GroupMember _memberFromJson(Json json) => GroupMember(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  role: GroupRole.fromApi(json['role'] as String?),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

SharedBudgetProgress _budgetFromJson(Json json) => SharedBudgetProgress(
  id: json['id'] as String,
  name: json['name'] as String,
  period: _period(json['period'] as String?),
  amount: _double(json['amount']),
  effectiveAmount: _double(json['effectiveAmount']),
  spent: _double(json['spent']),
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
);

BudgetPeriod _period(String? value) {
  for (final period in BudgetPeriod.values) {
    if (period.name == value) return period;
  }

  return BudgetPeriod.monthly;
}

List<Json> _list(Object? value) =>
    value is List ? [for (final item in value) item as Json] : const [];

double _double(Object? value) => (value as num).toDouble();

double? _doubleOrNull(Object? value) => value == null ? null : _double(value);
