import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<Either<CacheFailure, UserSettings>> getSettings();
  Future<Either<CacheFailure, UserSettings>> updateSettings(
    UserSettings settings,
  );
}
