import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/sync_engine.dart';
import '../entities/user.dart';

/// Repository for managing user authentication.
abstract class AuthRepository {
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

  /// Deletes the current user's account.
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

  /// Checks for sync conflicts with the remote server.
  Future<SyncConflictType> checkConflict();
}
