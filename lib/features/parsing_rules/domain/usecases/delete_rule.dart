import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../repositories/parsing_rules_repository.dart';

class DeleteRule implements UseCase<Unit, String> {
  final ParsingRulesRepository repository;

  DeleteRule(this.repository);

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return repository.deleteRule(id);
  }
}
