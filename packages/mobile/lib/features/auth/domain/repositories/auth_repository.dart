import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<void> get firstSyncNeeded;

  Future<Either<AuthFailure, User>> signInWithGoogle();

  Future<Either<AuthFailure, Unit>> signOut();

  Future<Either<AuthFailure, User?>> getCurrentUser();

  Future<Either<AuthFailure, bool>> isSignedIn();

  Future<Either<AuthFailure, Unit>> reauthenticate();

  Future<Either<Failure, Unit>> deleteServerAccount();

  Future<Either<AuthFailure, Unit>> deleteAccount();

  Future<void> stopSyncEngine();

  Future<void> startSyncEngine();

  Future<void> pauseSyncEngine();

  Future<void> resumeSyncEngine();

  Future<SyncConflictType> checkConflict();

  Future<bool> isSyncEnabled();
}
