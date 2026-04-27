import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/parsing_rule.dart';
import '../repositories/parsing_rules_repository.dart';

class GetRulesParams {
  final SourceType? sourceType;
  final bool? isEnabled;

  GetRulesParams({this.sourceType, this.isEnabled});
}

class GetRules implements UseCase<List<ParsingRule>, GetRulesParams> {
  final ParsingRulesRepository repository;

  GetRules(this.repository);

  @override
  Future<Either<Failure, List<ParsingRule>>> call(GetRulesParams params) {
    return repository.getRules(
      sourceType: params.sourceType,
      isEnabled: params.isEnabled,
    );
  }
}
