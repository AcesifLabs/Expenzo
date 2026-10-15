import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../repositories/data_wipe_repository.dart';

/// Deletes every local Record, Budget, category, recurring item, SMS rule and
/// goal, re-seeds default categories, resets Display Preferences, cancels
/// scheduled work and clears per-item prefs. Does not call the server or
/// touch sync. Used by Delete all data and Delete account.
class WipeLocalData implements UseCase<Unit, NoParams> {
  final DataWipeRepository repository;

  const WipeLocalData(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.wipeLocalData();
  }
}
