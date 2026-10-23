import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Fires when Sync is switched on before the first sync ran.
  Stream<void> get firstSyncNeeded;

  /// Signs in with Google and returns the authenticated [User].
  ///
  /// Returns [Right(User)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, User>> signInWithGoogle();

  /// Signs out the current user.
  ///
  /// Returns [Right(unit)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, Unit>> signOut();

  /// Returns the currently authenticated [User], or null if not signed in.
  ///
  /// Returns [Right(User?)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, User?>> getCurrentUser();

  /// Checks whether the user is currently signed in.
  ///
  /// Returns [Right(bool)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, bool>> isSignedIn();

  /// Refreshes the sign-in silently before an account delete.
  ///
  /// Returns [Left(AuthFailure)] with `FailureCodes.requiresRecentLogin`
  /// when the user has to sign in again first.
  Future<Either<AuthFailure, Unit>> reauthenticate();

  /// Deletes the account and its synced data on the server.
  ///
  /// Returns [Left] with a [NetworkFailure], [ServerFailure] or
  /// [AuthFailure] when the server didn't delete it.
  Future<Either<Failure, Unit>> deleteServerAccount();

  /// Deletes the Firebase user and signs out locally, even when the delete
  /// fails.
  ///
  /// Returns [Right(unit)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, Unit>> deleteAccount();

  /// Checks if the user has granted Gmail OAuth scope.
  ///
  /// Returns [Right(bool)] on success, [Left(AuthFailure)] on failure.
  Future<Either<AuthFailure, bool>> hasGmailScope();

  /// Stops the background sync engine.
  Future<void> stopSyncEngine();

  /// Starts the background sync engine.
  Future<void> startSyncEngine();

  /// Stops sync and keeps it off, even if something calls start, until
  /// [resumeSyncEngine].
  Future<void> pauseSyncEngine();

  /// Lifts [pauseSyncEngine] and starts sync; signed out it stays idle.
  Future<void> resumeSyncEngine();

  /// Checks for sync conflicts with the remote server.
  Future<SyncConflictType> checkConflict();

  /// Whether Sync is switched on for this device.
  Future<bool> isSyncEnabled();
}
