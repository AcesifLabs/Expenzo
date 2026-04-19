import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;

  SettingsRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<CacheFailure, UserSettings>> getSettings() async {
    try {
      final settings = await localDatasource.getSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<CacheFailure, UserSettings>> updateSettings(
    UserSettings settings,
  ) async {
    try {
      final updated = await localDatasource.updateSettings(settings);
      return Right(updated);
    } on CacheException catch (e) {
      return Left(e.toFailure());
    }
  }
}
