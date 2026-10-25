import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide ParsingRule;
import 'package:expense_tracker/core/database/daos/parsing_rule_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/parsing_rules/data/datasources/parsing_rules_local_datasource.dart';
import 'package:expense_tracker/features/parsing_rules/data/repositories/parsing_rules_repository_impl.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';

void main() {
  late AppDatabase db;
  late SyncQueueDao queue;
  late ParsingRulesRepositoryImpl repository;
  final createdAt = DateTime.utc(2026, 3, 1, 10);
  final updatedAt = DateTime.utc(2026, 3, 2, 11);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(db);
    repository = ParsingRulesRepositoryImpl(
      localDatasource: ParsingRulesLocalDatasourceImpl(ParsingRuleDao(db)),
      syncQueueDao: queue,
    );
  });

  tearDown(() => db.close());

  ParsingRule rule({String id = 'rule-1'}) => ParsingRule(
    id: id,
    name: 'Bank debit',
    triggerWords: const ['debited', 'spent'],
    amountPattern: r'[\d,]+\.\d{2}',
    datePattern: null,
    categoryId: 'cat-1',
    sourceType: SourceType.sms,
    isEnabled: true,
    priority: 10,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  test('createRule queues an insert with handler field names', () async {
    final saved = (await repository.createRule(
      rule(),
    )).getOrElse(() => throw StateError('create failed'));

    final row = (await queue.getUnsynced()).single;
    expect(row.entityTable, 'parsing_rules');
    expect(row.action, 'insert');
    expect(row.recordId, saved.id);
    expect(jsonDecode(row.payload), {
      'name': 'Bank debit',
      'triggerWords': jsonEncode(['debited', 'spent']),
      'amountPattern': r'[\d,]+\.\d{2}',
      'datePattern': null,
      'categoryId': 'cat-1',
      'sourceType': 'sms',
      'isEnabled': true,
      'priority': 10,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    });
  });

  test('updateRule queues an update', () async {
    await repository.createRule(rule());

    await repository.updateRule(rule().copyWith(name: 'Renamed'));

    final update = (await queue.getUnsynced()).last;
    expect(update.action, 'update');
    expect((jsonDecode(update.payload) as Map)['name'], 'Renamed');
  });

  test('deleteRule queues an empty delete', () async {
    await repository.createRule(rule());

    await repository.deleteRule('rule-1');

    final delete = (await queue.getUnsynced()).last;
    expect(delete.action, 'delete');
    expect(delete.payload, '');
  });

  test('writes skip the queue when syncQueueDao is null', () async {
    final localOnly = ParsingRulesRepositoryImpl(
      localDatasource: ParsingRulesLocalDatasourceImpl(ParsingRuleDao(db)),
    );

    await localOnly.createRule(rule(id: 'rule-2'));

    expect(await queue.getUnsynced(), isEmpty);
  });
}
