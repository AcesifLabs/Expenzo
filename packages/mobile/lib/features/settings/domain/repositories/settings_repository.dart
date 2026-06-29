import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/user_settings.dart';

/// Repository for managing user settings.
abstract class SettingsRepository {
  /// Retrieves the current user settings.
  ///
  /// Returns [Right(UserSettings)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, UserSettings>> getSettings();

  /// Updates and persists the given [settings].
  ///
  /// Returns [Right(UserSettings)] on success, [Left(CacheFailure)] on failure.
  Future<Either<CacheFailure, UserSettings>> updateSettings(
    UserSettings settings,
  );
}
