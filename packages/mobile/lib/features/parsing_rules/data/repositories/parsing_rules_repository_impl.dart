import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/sync/sync_event.dart';
import 'package:expense_tracker/core/sync/sync_table_names.dart';
import '../../domain/entities/parsing_rule.dart';
import '../../domain/repositories/parsing_rules_repository.dart';
import '../datasources/parsing_rules_local_datasource.dart';

class ParsingRulesRepositoryImpl implements ParsingRulesRepository {
  final ParsingRulesLocalDatasource localDatasource;
  final SyncQueueDao? _syncQueueDao;

  ParsingRulesRepositoryImpl({
    required this.localDatasource,
    SyncQueueDao? syncQueueDao,
  }) : _syncQueueDao = syncQueueDao;

  @override
  Future<Either<Failure, List<ParsingRule>>> getRules({
    SourceType? sourceType,
    bool? isEnabled,
  }) async {
    try {
      final rules = await localDatasource.getRules(
        sourceType: sourceType,
        isEnabled: isEnabled,
      );

      return Right(rules);
    } catch (e, s) {
      appLogger.error('Error getting rules', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsingRule>> getRuleById(String id) async {
    try {
      final rule = await localDatasource.getRuleById(id);
      if (rule == null) {
        return Left(CacheFailure(message: 'Rule not found'));
      }

      return Right(rule);
    } catch (e, s) {
      appLogger.error('Error getting rule by id', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsingRule>> createRule(ParsingRule rule) async {
    try {
      final createdRule = await localDatasource.createRule(rule);
      await _enqueueSync('insert', createdRule.id, _payload(createdRule));

      return Right(createdRule);
    } catch (e, s) {
      appLogger.error('Error creating rule', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsingRule>> updateRule(ParsingRule rule) async {
    try {
      final updatedRule = await localDatasource.updateRule(rule);
      await _enqueueSync('update', updatedRule.id, _payload(updatedRule));

      return Right(updatedRule);
    } catch (e, s) {
      appLogger.error('Error updating rule', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRule(String id) async {
    try {
      await localDatasource.deleteRule(id);
      await _enqueueSync('delete', id);

      return const Right(unit);
    } catch (e, s) {
      appLogger.error('Error deleting rule', e, s);

      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ParsingRule>> watchRules() {
    return localDatasource.watchRules();
  }

  Map<String, dynamic> _payload(ParsingRule rule) => {
    'name': rule.name,
    'triggerWords': jsonEncode(rule.triggerWords),
    'amountPattern': rule.amountPattern,
    'datePattern': rule.datePattern,
    'categoryId': rule.categoryId,
    'sourceType': rule.sourceType.name,
    'isEnabled': rule.isEnabled,
    'priority': rule.priority,
    'createdAt': rule.createdAt.toUtc().toIso8601String(),
    'updatedAt': rule.updatedAt.toUtc().toIso8601String(),
  };

  Future<void> _enqueueSync(
    String action,
    String id, [
    Map<String, dynamic>? data,
  ]) async {
    final syncQueueDao = _syncQueueDao;
    if (syncQueueDao == null) return;
    await syncQueueDao.enqueue(
      tableName: SyncTableNames.parsingRules,
      recordId: id,
      action: action,
      payload: data != null ? jsonEncode(data) : '',
    );
    SyncEventBus().trigger();
  }
}
