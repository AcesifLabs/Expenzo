import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettings extends UseCase<UserSettings, UserSettings> {
  final SettingsRepository repository;

  UpdateSettings(this.repository);

  @override
  Future<Either<Failure, UserSettings>> call(UserSettings settings) {
    return repository.updateSettings(settings);
  }
}
