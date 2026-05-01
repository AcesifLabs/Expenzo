import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';

void initSettingsModule(GetIt getIt) {
  getIt.registerLazySingleton<SettingsLocalDatasource>(
    () => SettingsLocalDatasourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDatasource: getIt<SettingsLocalDatasource>(),
    ),
  );

  getIt.registerLazySingleton(() => GetSettings(getIt<SettingsRepository>()));
  getIt.registerLazySingleton(
    () => UpdateSettings(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(
      getSettings: getIt<GetSettings>(),
      updateSettings: getIt<UpdateSettings>(),
    ),
  );
}
