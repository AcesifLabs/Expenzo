import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/family/data/services/group_refresh_policy.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_my_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/factories/family_factory.dart';
import '../../../support/shared_budget_rows.dart';

class _MockGetMyGroup extends Mock implements GetMyGroup {}

void main() {
  late AppDatabase db;
  late _MockGetMyGroup getMyGroup;
  late DateTime now;
  MyGroup? cached;

  GroupRefreshPolicy policy() => GroupRefreshPolicy(
    cachedGroup: () => cached,
    budgetDao: db.budgetDao,
    getMyGroup: getMyGroup,
    clock: () => now,
  );

  setUpAll(() => registerFallbackValue(const GetMyGroupParams()));

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    getMyGroup = _MockGetMyGroup();
    when(
      () => getMyGroup(any()),
    ).thenAnswer((_) async => Right(Cached(cached, fetchedAt: now)));
    now = DateTime(2026, 4, 15, 12);
    cached = null;
  });
  tearDown(() => db.close());

  test(
    'makes no request for a user with no group and no shared budgets',
    () async {
      await policy().refreshIfDue();

      verifyNever(() => getMyGroup(any()));
    },
  );

  test('refreshes when shared budgets exist without a cached group', () async {
    await insertBudgetRow(db, 'shared', groupId: 'group-1');

    await policy().refreshIfDue();

    verify(() => getMyGroup(const GetMyGroupParams())).called(1);
  });

  test('refreshes a cached group at most once per 15 minutes', () async {
    cached = makeMyGroup();
    final p = policy();

    await p.refreshIfDue();
    now = now.add(const Duration(minutes: 14));
    await p.refreshIfDue();
    now = now.add(const Duration(minutes: 1));
    await p.refreshIfDue();

    verify(() => getMyGroup(any())).called(2);
  });
}
