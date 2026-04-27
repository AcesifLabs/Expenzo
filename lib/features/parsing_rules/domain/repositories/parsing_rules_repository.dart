import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/parsing_rule.dart';

abstract class ParsingRulesRepository {
  Future<Either<Failure, List<ParsingRule>>> getRules({
    SourceType? sourceType,
    bool? isEnabled,
  });
  Future<Either<Failure, ParsingRule>> getRuleById(String id);
  Future<Either<Failure, ParsingRule>> createRule(ParsingRule rule);
  Future<Either<Failure, ParsingRule>> updateRule(ParsingRule rule);
  Future<Either<Failure, Unit>> deleteRule(String id);
  Stream<List<ParsingRule>> watchRules();
}
