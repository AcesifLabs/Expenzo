import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:expense_tracker/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';

import '../../../support/factories/budget_factory.dart';

class _MockBudgetLocalDatasource extends Mock
    implements BudgetLocalDatasource {}

class _MockSyncQueueDao extends Mock implements SyncQueueDao {}

class _BudgetFake extends Fake implements Budget {}

void main() {
  late _MockBudgetLocalDatasource datasource;
  late _MockSyncQueueDao syncQueueDao;
  late BudgetRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(_BudgetFake()));

  setUp(() {
    datasource = _MockBudgetLocalDatasource();
    syncQueueDao = _MockSyncQueueDao();
    repository = BudgetRepositoryImpl(
      localDatasource: datasource,
      syncQueueDao: syncQueueDao,
    );
    when(() => datasource.createBudget(any())).thenAnswer((_) async {});
    when(() => datasource.updateBudget(any())).thenAnswer((_) async {});
    when(
      () => syncQueueDao.enqueue(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        action: any(named: 'action'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
  });

  Map<String, dynamic> enqueuedPayload() {
    final payload =
        verify(
              () => syncQueueDao.enqueue(
                tableName: 'budgets',
                recordId: any(named: 'recordId'),
                action: any(named: 'action'),
                payload: captureAny(named: 'payload'),
              ),
            ).captured.single
            as String;

    return jsonDecode(payload) as Map<String, dynamic>;
  }

  test('creating a shared budget enqueues its groupId', () async {
    await repository.createBudget(makeBudget(groupId: 'group-1'));

    expect(enqueuedPayload()['groupId'], 'group-1');
  });

  test('updating a budget enqueues groupId, null included', () async {
    await repository.updateBudget(makeBudget());

    final payload = enqueuedPayload();
    expect(payload.containsKey('groupId'), isTrue);
    expect(payload['groupId'], isNull);
  });

  test('copyWith(groupId: null) clears it and omitting it keeps it', () {
    final shared = makeBudget(groupId: 'group-1');

    expect(shared.copyWith(groupId: null).groupId, isNull);
    expect(shared.copyWith(name: 'Rent').groupId, 'group-1');
    expect(shared.isShared, isTrue);
  });
}
