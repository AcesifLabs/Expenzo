import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/local_data_summary.dart';

abstract class DataWipeRepository {
  Future<Either<Failure, LocalDataSummary>> countData();

  Future<bool> isSignedIn();

  Future<Either<Failure, Unit>> wipeLocalData();

  Future<Either<Failure, Unit>> deleteAllData();
}
