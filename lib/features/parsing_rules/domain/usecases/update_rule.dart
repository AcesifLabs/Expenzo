import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
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
