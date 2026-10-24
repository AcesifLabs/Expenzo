import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/resolve_onboarding_status.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';

/// The parts that only need critical dependencies (run on every start).
void initOnboardingCoreModule(GetIt getIt) {
  getIt.registerLazySingleton(
    () => OnboardingLocalDatasource(db: getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton(
    () => ResolveOnboardingStatus(
      getSettings: getIt<GetSettings>(),
      updateSettings: getIt<UpdateSettings>(),
      local: getIt<OnboardingLocalDatasource>(),
    ),
  );
}

/// Needs the budget, recurring and goals feature modules, so it runs in
/// `initFeatureDependencies`.
void initOnboardingFeatureModule(GetIt getIt) {
  getIt.registerLazySingleton(
    () => CompleteOnboarding(
      recurringRepository: getIt<RecurringRepository>(),
      budgetRepository: getIt<BudgetRepository>(),
      goalRepository: getIt<GoalRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
    ),
  );
  getIt.registerFactory(
    () => OnboardingBloc(
      completeOnboarding: getIt<CompleteOnboarding>(),
      getSettings: getIt<GetSettings>(),
    ),
  );
}
