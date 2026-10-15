import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/local_data_summary.dart';
import '../repositories/data_wipe_repository.dart';

/// How much Delete all data will erase on this device.
class GetLocalDataSummary implements UseCase<LocalDataSummary, NoParams> {
  final DataWipeRepository repository;

  const GetLocalDataSummary(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, LocalDataSummary>> call(NoParams params) {
    return repository.countData();
  }
}
