import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

import '../entities/local_data_summary.dart';

abstract class DataWipeRepository {
  Future<Either<Failure, LocalDataSummary>> countData();

  /// The only signed-in check for Delete all data.
  Future<bool> isSignedIn();

  /// The local half of a delete: tables, settings, scheduled work and prefs.
  /// Never calls the server or touches sync.
  Future<Either<Failure, Unit>> wipeLocalData();

  /// Clears the account's synced copy when signed in, then wipes locally.
  /// Nothing local changes when the server step fails.
  Future<Either<Failure, Unit>> deleteAllData();
}
