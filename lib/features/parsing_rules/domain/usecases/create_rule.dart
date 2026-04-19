import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/parsing_rule.dart';
import '../repositories/parsing_rules_repository.dart';

class CreateRule implements UseCase<ParsingRule, ParsingRule> {
  final ParsingRulesRepository repository;

  CreateRule(this.repository);

  @override
  Future<Either<Failure, ParsingRule>> call(ParsingRule rule) {
    return repository.createRule(rule);
  }
}
