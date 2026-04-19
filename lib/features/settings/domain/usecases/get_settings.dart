import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/user_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings extends UseCase<UserSettings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<Either<Failure, UserSettings>> call(NoParams params) {
    return repository.getSettings();
  }
}
