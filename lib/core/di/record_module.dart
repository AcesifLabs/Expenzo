import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_record_from_parsed.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';

void initRecordModule(GetIt getIt) {
  getIt.registerLazySingleton<RecordLocalDatasource>(
    () => RecordLocalDatasourceImpl(recordDao: getIt<RecordDao>()),
  );
  getIt.registerLazySingleton<RecordRepository>(
    () => RecordRepositoryImpl(localDatasource: getIt<RecordLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetRecords(getIt<RecordRepository>()));
  getIt.registerLazySingleton(() => AddRecord(getIt<RecordRepository>()));
  getIt.registerLazySingleton(() => UpdateRecord(getIt<RecordRepository>()));
  getIt.registerLazySingleton(() => DeleteRecord(getIt<RecordRepository>()));
  getIt.registerLazySingleton(
    () => CreateRecordFromParsed(getIt<RecordRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreateRecordsFromParsedList(getIt<RecordRepository>()),
  );
  getIt.registerFactory<RecordBloc>(
    () => RecordBloc(
      getRecords: getIt<GetRecords>(),
      addRecord: getIt<AddRecord>(),
      updateRecord: getIt<UpdateRecord>(),
      deleteRecord: getIt<DeleteRecord>(),
      recordRepository: getIt<RecordRepository>(),
    ),
  );
}
