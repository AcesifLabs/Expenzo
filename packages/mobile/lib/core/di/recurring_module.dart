import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/get_recurring_list.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/create_recurring.dart'
    as create_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/update_recurring.dart'
    as update_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/delete_recurring.dart'
    as delete_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart'
    as process_uc;
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';

void initRecurringModule(GetIt getIt) {
  getIt.registerLazySingleton<RecurringLocalDatasource>(
    () => RecurringLocalDatasourceImpl(
      recurringDao: getIt<AppDatabase>().recurringDao,
    ),
  );
  getIt.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(
      localDatasource: getIt<RecurringLocalDatasource>(),
      pendingRecurringDao: getIt<PendingRecurringDao>(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetRecurringList(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => create_uc.CreateRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => update_uc.UpdateRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => delete_uc.DeleteRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerLazySingleton(
    () => process_uc.ProcessRecurring(getIt<RecurringRepository>()),
  );
  getIt.registerFactory<RecurringBloc>(
    () => RecurringBloc(
      getRecurringList: getIt<GetRecurringList>(),
      createRecurring: getIt<create_uc.CreateRecurring>(),
      updateRecurring: getIt<update_uc.UpdateRecurring>(),
      deleteRecurring: getIt<delete_uc.DeleteRecurring>(),
      processRecurring: getIt<process_uc.ProcessRecurring>(),
      addRecord: getIt<AddRecord>(),
    ),
  );
}
