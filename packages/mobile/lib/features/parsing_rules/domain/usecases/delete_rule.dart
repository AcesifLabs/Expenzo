import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/parsing_rules_repository.dart';

class DeleteRule implements UseCase<Unit, String> {
  final ParsingRulesRepository repository;

  DeleteRule(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteRule(id);
  }
}
