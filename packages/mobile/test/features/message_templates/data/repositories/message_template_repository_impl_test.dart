import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide ExpenseTemplate, MessageSource;
import 'package:expense_tracker/core/database/daos/message_template_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/message_templates/data/datasources/message_template_local_datasource.dart';
import 'package:expense_tracker/features/message_templates/data/repositories/message_template_repository_impl.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/expense_template.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';

void main() {
  late AppDatabase db;
  late SyncQueueDao queue;
  late MessageTemplateRepositoryImpl repository;
  final createdAt = DateTime.utc(2026, 4, 1, 8);
  final updatedAt = DateTime.utc(2026, 4, 2, 9);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queue = SyncQueueDao(db);
    repository = MessageTemplateRepositoryImpl(
      localDatasource: MessageTemplateLocalDatasourceImpl(
        MessageTemplateDao(db),
      ),
      syncQueueDao: queue,
    );
  });

  tearDown(() => db.close());

  MessageSource source({String id = 'src-1'}) => MessageSource(
    id: id,
    contactId: 'BKASH',
    contactName: 'bKash',
    isMonitored: true,
    autoCreateOption: AutoCreateOption.promptUser,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  ExpenseTemplate template({String id = 'tpl-1'}) => ExpenseTemplate(
    id: id,
    sourceId: 'src-1',
    sampleMessage: 'Tk 500.00 paid',
    triggerWord: 'paid',
    amountPattern: r'Tk ([\d,]+\.\d{2})',
    descriptionPattern: null,
    datePattern: null,
    categoryId: 'cat-1',
    selectedAmount: '500.00',
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  test('saveMessageSource queues insert then update', () async {
    await repository.saveMessageSource(source());

    final insert = (await queue.getUnsynced()).single;
    expect(insert.entityTable, 'message_sources');
    expect(insert.action, 'insert');
    expect(jsonDecode(insert.payload), {
      'contactId': 'BKASH',
      'contactName': 'bKash',
      'isMonitored': true,
      'autoCreateOption': AutoCreateOption.promptUser.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    });

    await repository.saveMessageSource(
      source().copyWith(contactName: 'bKash Ltd'),
    );

    final update = (await queue.getUnsynced()).last;
    expect(update.action, 'update');
    expect((jsonDecode(update.payload) as Map)['contactName'], 'bKash Ltd');
  });

  test('deleteMessageSource queues an empty delete', () async {
    await repository.saveMessageSource(source());

    await repository.deleteMessageSource('src-1');

    final delete = (await queue.getUnsynced()).last;
    expect(delete.entityTable, 'message_sources');
    expect(delete.action, 'delete');
    expect(delete.payload, '');
  });

  test('saveTemplate queues insert then update', () async {
    await repository.saveMessageSource(source());
    await repository.saveTemplate(template());

    final insert = (await queue.getUnsynced()).lastWhere(
      (row) => row.entityTable == 'expense_templates',
    );
    expect(insert.action, 'insert');
    expect(jsonDecode(insert.payload), {
      'sourceId': 'src-1',
      'sampleMessage': 'Tk 500.00 paid',
      'triggerWord': 'paid',
      'amountPattern': r'Tk ([\d,]+\.\d{2})',
      'descriptionPattern': null,
      'datePattern': null,
      'categoryId': 'cat-1',
      'selectedAmount': '500.00',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    });

    await repository.saveTemplate(
      template().copyWith(
        id: 'tpl-1',
        sourceId: 'src-1',
        sampleMessage: 'Tk 500.00 paid',
        triggerWord: 'debited',
        amountPattern: r'Tk ([\d,]+\.\d{2})',
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );

    final update = (await queue.getUnsynced()).last;
    expect(update.action, 'update');
    expect((jsonDecode(update.payload) as Map)['triggerWord'], 'debited');
  });

  test('deleteTemplate queues an empty delete', () async {
    await repository.saveMessageSource(source());
    await repository.saveTemplate(template());

    await repository.deleteTemplate('tpl-1');

    final delete = (await queue.getUnsynced()).last;
    expect(delete.entityTable, 'expense_templates');
    expect(delete.action, 'delete');
    expect(delete.payload, '');
  });

  test('writes skip the queue when syncQueueDao is null', () async {
    final localOnly = MessageTemplateRepositoryImpl(
      localDatasource: MessageTemplateLocalDatasourceImpl(
        MessageTemplateDao(db),
      ),
    );

    await localOnly.saveMessageSource(source(id: 'src-2'));

    expect(
      (await queue.getUnsynced()).where((r) => r.recordId == 'src-2'),
      isEmpty,
    );
  });
}
