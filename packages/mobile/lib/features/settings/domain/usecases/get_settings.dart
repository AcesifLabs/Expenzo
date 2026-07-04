import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings extends UseCase<UserSettings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, UserSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}
