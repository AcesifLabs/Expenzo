import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/parsing_rule.dart';
import '../repositories/parsing_rules_repository.dart';

class CreateRule implements UseCase<ParsingRule, ParsingRule> {
  final ParsingRulesRepository repository;

  CreateRule(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, ParsingRule>> call(ParsingRule rule) {
    return repository.createRule(rule);
  }
}
