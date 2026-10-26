import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/features/export/data/datasources/export_local_datasource.dart';
import 'package:expense_tracker/features/export/data/repositories/export_repository_impl.dart';
import 'package:expense_tracker/features/export/data/services/export_csv_builder.dart';
import 'package:expense_tracker/features/export/domain/repositories/export_repository.dart';
import 'package:expense_tracker/features/export/domain/usecases/export_data.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_bloc.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';

void initExportModule(GetIt getIt) {
  getIt.registerLazySingleton(() => const ExportCsvBuilder());

  getIt.registerLazySingleton<ExportLocalDatasource>(
    () => ExportLocalDatasourceImpl(
      recordDao: getIt<RecordDao>(),
      categoryDao: getIt<CategoryDao>(),
      budgetDao: getIt<BudgetDao>(),
      tempDirectory: getTemporaryDirectory,
      currencyCode: () => _currencyCode(getIt<GetSettings>()),
      builder: getIt<ExportCsvBuilder>(),
    ),
  );

  getIt.registerLazySingleton<ExportRepository>(
    () => ExportRepositoryImpl(localDatasource: getIt<ExportLocalDatasource>()),
  );

  getIt.registerLazySingleton(() => ExportData(getIt<ExportRepository>()));
  getIt.registerLazySingleton(() => const FileShareService());

  getIt.registerFactory(
    () => ExportBloc(
      exportData: getIt<ExportData>(),
      shareService: getIt<FileShareService>(),
    ),
  );
}

Future<String> _currencyCode(GetSettings getSettings) async {
  final result = await getSettings(NoParams());

  return result.fold(
    (_) => CurrencyConfig.defaultCode,
    (settings) => settings.currencyCode,
  );
}
