import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';

import '../entities/local_data_summary.dart';
import '../repositories/data_wipe_repository.dart';

class GetLocalDataSummary implements UseCase<LocalDataSummary, NoParams> {
  final DataWipeRepository repository;

  const GetLocalDataSummary(this.repository);

  @override
  Future<Either<Failure, LocalDataSummary>> call(NoParams params) {
    return repository.countData();
  }
}
