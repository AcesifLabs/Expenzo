import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/sync/sync_table_names.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../../domain/repositories/message_template_repository.dart';
import '../datasources/message_template_local_datasource.dart';

class MessageTemplateRepositoryImpl implements MessageTemplateRepository {
  final MessageTemplateLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  MessageTemplateRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  @override
  Future<Either<Failure, List<MessageSource>>> getMessageSources() async {
    try {
      final sources = await localDatasource.getMessageSources();

      return Right(sources);
    } catch (e, s) {
      appLogger.error('Error getting message sources', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageSource>> saveMessageSource(
    MessageSource source,
  ) async {
    try {
      final existing = await localDatasource.getMessageSourceById(source.id);
      final saved = await localDatasource.saveMessageSource(source);
      await _enqueueSync(
        SyncTableNames.messageSources,
        existing == null ? 'insert' : 'update',
        saved.id,
        _sourcePayload(saved),
      );

      return Right(saved);
    } catch (e, s) {
      appLogger.error('Error saving message source', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessageSource(String id) async {
    try {
      await localDatasource.deleteMessageSource(id);
      await _enqueueSync(SyncTableNames.messageSources, 'delete', id);

      return const Right(unit);
    } catch (e, s) {
      appLogger.error('Error deleting message source', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MessageSource>> watchMessageSources() {
    return localDatasource.watchMessageSources();
  }

  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getTemplatesForSource(
    String sourceId,
  ) async {
    try {
      final templates = await localDatasource.getTemplatesForSource(sourceId);

      return Right(templates);
    } catch (e, s) {
      appLogger.error('Error getting templates for source', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getAllTemplates() async {
    try {
      final templates = await localDatasource.getAllTemplates();

      return Right(templates);
    } catch (e, s) {
      appLogger.error('Error getting all templates', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseTemplate>> saveTemplate(
    ExpenseTemplate template,
  ) async {
    try {
      final existing = await localDatasource.getTemplateById(template.id);
      final saved = await localDatasource.saveTemplate(template);
      await _enqueueSync(
        SyncTableNames.expenseTemplates,
        existing == null ? 'insert' : 'update',
        saved.id,
        _templatePayload(saved),
      );

      return Right(saved);
    } catch (e, s) {
      appLogger.error('Error saving template', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTemplate(String id) async {
    try {
      await localDatasource.deleteTemplate(id);
      await _enqueueSync(SyncTableNames.expenseTemplates, 'delete', id);

      return const Right(unit);
    } catch (e, s) {
      appLogger.error('Error deleting template', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId) {
    return localDatasource.watchTemplatesForSource(sourceId);
  }

  Map<String, dynamic> _sourcePayload(MessageSource source) => {
    'contactId': source.contactId,
    'contactName': source.contactName,
    'isMonitored': source.isMonitored,
    'autoCreateOption': source.autoCreateOption.index,
    'createdAt': source.createdAt.toUtc().toIso8601String(),
    'updatedAt': source.updatedAt.toUtc().toIso8601String(),
  };

  Map<String, dynamic> _templatePayload(ExpenseTemplate template) => {
    'sourceId': template.sourceId,
    'sampleMessage': template.sampleMessage,
    'triggerWord': template.triggerWord,
    'amountPattern': template.amountPattern,
    'descriptionPattern': template.descriptionPattern,
    'datePattern': template.datePattern,
    'categoryId': template.categoryId,
    'selectedAmount': template.selectedAmount,
    'createdAt': template.createdAt.toUtc().toIso8601String(),
    'updatedAt': template.updatedAt.toUtc().toIso8601String(),
  };

  Future<void> _enqueueSync(
    String tableName,
    String action,
    String id, [
    Map<String, dynamic>? data,
  ]) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      tableName: tableName,
      recordId: id,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
