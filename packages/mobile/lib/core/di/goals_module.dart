import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/goals_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:expense_tracker/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:expense_tracker/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_tracker/features/goals/domain/usecases/add_goal_contribution.dart';
import 'package:expense_tracker/features/goals/domain/usecases/create_goal.dart';
import 'package:expense_tracker/features/goals/domain/usecases/delete_goal.dart';
import 'package:expense_tracker/features/goals/domain/usecases/get_active_goal.dart';
import 'package:expense_tracker/features/goals/domain/usecases/update_goal.dart';
import 'package:expense_tracker/features/goals/domain/usecases/watch_goals.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_form_bloc.dart';

void initGoalsModule(GetIt getIt) {
  getIt.registerLazySingleton<GoalLocalDatasource>(
    () => GoalLocalDatasourceImpl(goalsDao: getIt<GoalsDao>()),
  );
  getIt.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(
      localDatasource: getIt<GoalLocalDatasource>(),
      syncQueueDao: getIt<SyncQueueDao>(),
    ),
  );
  getIt.registerLazySingleton(
    () => CreateGoal(repository: getIt<GoalRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateGoal(repository: getIt<GoalRepository>()),
  );
  getIt.registerLazySingleton(
    () => AddGoalContribution(repository: getIt<GoalRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetActiveGoal(repository: getIt<GoalRepository>()),
  );
  getIt.registerLazySingleton(
    () => WatchGoals(repository: getIt<GoalRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteGoal(repository: getIt<GoalRepository>()),
  );
  getIt.registerFactory(
    () => GoalBloc(
      watchGoals: getIt<WatchGoals>(),
      addGoalContribution: getIt<AddGoalContribution>(),
    ),
  );
  getIt.registerFactory(
    () => GoalFormBloc(
      repository: getIt<GoalRepository>(),
      createGoal: getIt<CreateGoal>(),
      updateGoal: getIt<UpdateGoal>(),
      deleteGoal: getIt<DeleteGoal>(),
    ),
  );
}
