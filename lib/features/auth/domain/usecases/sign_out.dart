import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../repositories/auth_repository.dart';

class SignOut extends UseCase<Unit, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.signOut();
  }
}
