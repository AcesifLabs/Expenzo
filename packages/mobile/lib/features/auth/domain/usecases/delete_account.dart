import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccount extends UseCase<Unit, NoParams> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.deleteAccount();
  }
}
