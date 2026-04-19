import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<Either<CacheFailure, UserSettings>> getSettings();
  Future<Either<CacheFailure, UserSettings>> updateSettings(
    UserSettings settings,
  );
}
