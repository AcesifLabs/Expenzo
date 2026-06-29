import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/parsing_rule.dart';
import '../../domain/repositories/parsing_rules_repository.dart';
import '../datasources/parsing_rules_local_datasource.dart';

class ParsingRulesRepositoryImpl implements ParsingRulesRepository {
  final ParsingRulesLocalDatasource localDatasource;

  ParsingRulesRepositoryImpl({required this.localDatasource});

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
    } catch (e) {
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
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsingRule>> createRule(ParsingRule rule) async {
    try {
      final createdRule = await localDatasource.createRule(rule);

      return Right(createdRule);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsingRule>> updateRule(ParsingRule rule) async {
    try {
      final updatedRule = await localDatasource.updateRule(rule);

      return Right(updatedRule);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRule(String id) async {
    try {
      await localDatasource.deleteRule(id);

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ParsingRule>> watchRules() {
    return localDatasource.watchRules();
  }
}
