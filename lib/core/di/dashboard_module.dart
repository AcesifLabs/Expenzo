import 'package:get_it/get_it.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/records/domain/repositories/record_repository.dart';
import '../../features/categories/domain/repositories/category_repository.dart';

void initDashboardModule(GetIt getIt) {
  getIt.registerLazySingleton<GetDashboardSummaryUseCase>(
    () => GetDashboardSummaryUseCase(
      recordRepository: getIt<RecordRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<DashboardBloc>(
    () =>
        DashboardBloc(getDashboardSummary: getIt<GetDashboardSummaryUseCase>()),
  );
}
