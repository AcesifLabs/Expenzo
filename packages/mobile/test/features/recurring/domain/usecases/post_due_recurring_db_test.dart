import 'package:dartz/dartz.dart';
import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart' hide Record;
import 'package:expense_tracker/core/database/daos/pending_recurring_dao.dart';
import 'package:expense_tracker/core/database/daos/record_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/core/database/transaction_runner.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/recurring/data/datasources/recurring_local_datasource.dart';
import 'package:expense_tracker/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/post_due_recurring.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/recurring_factory.dart';

class _MockRemote extends Mock implements RecordRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockGetCategories extends Mock implements GetCategories {}

/// Writes the Records, then reports a failure, as a disk error after the
/// insert would.
class _FailingRecordRepository extends RecordRepositoryImpl {
  _FailingRecordRepository({
    required super.localDatasource,
    required super.remoteDatasource,
    required super.connectivity,
    super.syncQueueDao,
  });

  @override
  Future<Either<CacheFailure, Unit>> addRecordsBatch(
    List<Record> records,
  ) async {
    await super.addRecordsBatch(records);

    return const Left(CacheFailure(message: 'disk full'));
  }
}

void main() {
  late AppDatabase db;
  late RecurringRepositoryImpl recurringRepository;
  late _MockCategoryRepository categoryRepository;
  late _MockGetCategories getCategories;

  final today = DateTime.now();
  final twoDaysAgo = DateTime(today.year, today.month, today.day - 2);

  setUpAll(() => registerFallbackValue(const GetCategoriesParams()));

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    recurringRepository = RecurringRepositoryImpl(
      localDatasource: RecurringLocalDatasourceImpl(
        recurringDao: db.recurringDao,
      ),
      pendingRecurringDao: PendingRecurringDao(db),
      syncQueueDao: SyncQueueDao(db),
    );
    categoryRepository = _MockCategoryRepository();
    getCategories = _MockGetCategories();
    when(() => getCategories(any())).thenAnswer((_) async => const Right([]));
    await recurringRepository.createRecurring(
      makeRecurring(
        id: 'rent',
        frequency: RecurringFrequency.daily,
        nextOccurrence: twoDaysAgo,
      ),
    );
  });

  tearDown(() => db.close());

  PostDueRecurring postWith(RecordRepositoryImpl recordRepository) =>
      PostDueRecurring(
        processRecurring: ProcessRecurring(recurringRepository),
        recordRepository: recordRepository,
        categoryRepository: categoryRepository,
        getCategories: getCategories,
        transactionRunner: DriftTransactionRunner(db),
      );

  RecordRepositoryImpl records({bool failing = false}) {
    final local = RecordLocalDatasourceImpl(recordDao: RecordDao(db));

    return failing
        ? _FailingRecordRepository(
            localDatasource: local,
            remoteDatasource: _MockRemote(),
            connectivity: _MockConnectivity(),
            syncQueueDao: SyncQueueDao(db),
          )
        : RecordRepositoryImpl(
            localDatasource: local,
            remoteDatasource: _MockRemote(),
            connectivity: _MockConnectivity(),
            syncQueueDao: SyncQueueDao(db),
          );
  }

  Future<DateTime> nextOccurrence() async =>
      (await recurringRepository.getRecurringById(
        'rent',
      )).getOrElse(() => throw StateError('missing')).nextOccurrence;

  Future<List<String>> queuedTables() async => [
    for (final entry in await SyncQueueDao(db).getUnsynced()) entry.entityTable,
  ];

  test('posts each occurrence, moves the date and queues both', () async {
    final result = await postWith(records())();

    final created = result.getOrElse(() => throw StateError('failed'));
    expect(created, greaterThanOrEqualTo(2));
    expect(await db.select(db.records).get(), hasLength(created));
    expect((await nextOccurrence()).isAfter(today), isTrue);
    // Every Record is queued for sync, plus the item's insert and update.
    final queued = await queuedTables();
    expect(queued.where((t) => t == 'records'), hasLength(created));
    expect(queued.where((t) => t == 'recurring_transactions'), hasLength(2));
  });

  test('a failure while adding rolls back the Records and the date', () async {
    final result = await postWith(records(failing: true))();

    expect(result.isLeft(), isTrue);
    expect(await db.select(db.records).get(), isEmpty);
    expect(await nextOccurrence(), twoDaysAgo);
    expect(await queuedTables(), ['recurring_transactions']);
  });
}
