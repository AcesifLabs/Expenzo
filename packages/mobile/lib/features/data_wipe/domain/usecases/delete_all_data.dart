import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/data_wipe_repository.dart';

/// Delete all data: clears the account's synced copy first when signed in,
/// then runs the local wipe. Stops before touching local data if the server
/// step fails.
class DeleteAllData implements UseCase<Unit, NoParams> {
  final DataWipeRepository repository;

  const DeleteAllData(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.deleteAllData();
  }
}
