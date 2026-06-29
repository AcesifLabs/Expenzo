import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/repositories/reports_repository.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_trend.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_insights.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_bloc.dart';

void initReportModule(GetIt getIt) {
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      recordDao: getIt<RecordDao>(),
      categoryDao: getIt<CategoryDao>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetSpendingTrend(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetCategoryBreakdown(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSpendingInsights(repository: getIt<ReportsRepository>()),
  );
  getIt.registerFactory<ReportsBloc>(
    () => ReportsBloc(
      getSpendingTrend: getIt<GetSpendingTrend>(),
      getCategoryBreakdown: getIt<GetCategoryBreakdown>(),
      getSpendingInsights: getIt<GetSpendingInsights>(),
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      granularity: Granularity.daily,
    ),
  );
}
