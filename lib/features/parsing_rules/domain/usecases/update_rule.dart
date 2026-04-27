import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/parsing_rule.dart';
import '../repositories/parsing_rules_repository.dart';

class UpdateRule implements UseCase<ParsingRule, ParsingRule> {
  final ParsingRulesRepository repository;

  UpdateRule(this.repository);

  @override
  Future<Either<Failure, ParsingRule>> call(ParsingRule rule) {
    return repository.updateRule(rule);
  }
}
