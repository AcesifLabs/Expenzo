import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockGetRecords extends Mock implements GetRecords {}

class MockAddRecord extends Mock implements AddRecord {}

class MockUpdateRecord extends Mock implements UpdateRecord {}

class MockDeleteRecord extends Mock implements DeleteRecord {}

class FakeGetRecordsParams extends Fake implements GetRecordsParams {}

Record _testRecord({String id = 'rec-1'}) => Record(
  id: id,
  amount: 100.0,
  description: 'Test',
  date: DateTime(2024, 1, 15),
  categoryId: 'cat-1',
  recordType: RecordType.expense,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

Future<List<RecordState>> collectStates(RecordBloc bloc, {int count = 3}) {
  final states = <RecordState>[];
  final sub = bloc.stream.listen(states.add);
  return Future<List<RecordState>>.delayed(
    const Duration(milliseconds: 100),
    () {
      sub.cancel();
      return states;
    },
  );
}

void main() {
  late MockRecordRepository mockRepo;
  late MockGetRecords mockGetRecords;
  late MockAddRecord mockAddRecord;
  late MockUpdateRecord mockUpdateRecord;
  late MockDeleteRecord mockDeleteRecord;
  late RecordBloc bloc;
  // Live queries that send when the test says, like drift's watch().
  late StreamController<List<Record>> allRecords;
  late StreamController<List<Record>> filteredRecords;

  setUpAll(() {
    registerFallbackValue(FakeGetRecordsParams());
    registerFallbackValue(RecordFilter());
  });

  setUp(() {
    mockRepo = MockRecordRepository();
    mockGetRecords = MockGetRecords();
    mockAddRecord = MockAddRecord();
    mockUpdateRecord = MockUpdateRecord();
    mockDeleteRecord = MockDeleteRecord();

    allRecords = StreamController<List<Record>>.broadcast();
    filteredRecords = StreamController<List<Record>>.broadcast();
    when(
      () => mockRepo.watchRecords(limit: any(named: 'limit')),
    ).thenAnswer((_) => allRecords.stream);
    when(
      () => mockRepo.watchFilteredRecords(any()),
    ).thenAnswer((_) => filteredRecords.stream);

    bloc = RecordBloc(
      getRecords: mockGetRecords,
      addRecord: mockAddRecord,
      updateRecord: mockUpdateRecord,
      deleteRecord: mockDeleteRecord,
      recordRepository: mockRepo,
    );
  });

  tearDown(() async {
    await bloc.close();
    await allRecords.close();
    await filteredRecords.close();
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  Future<void> applyCategoryFilter() async {
    when(
      () => mockRepo.getFilteredRecords(any()),
    ).thenAnswer((_) async => Right([_testRecord(id: 'filtered-1')]));
    bloc.add(const ApplyFilters(categoryIds: ['cat-1']));
    await settle();
  }

  group('live updates', () {
    test('an unfiltered update does not replace the filtered list', () async {
      await applyCategoryFilter();

      allRecords.add([_testRecord(id: 'other-category')]);
      await settle();

      final loaded = bloc.state as RecordLoaded;
      expect(loaded.records.map((r) => r.id), ['filtered-1']);
      expect(loaded.filterCategoryIds, ['cat-1']);
    });

    test('a filtered update replaces the list and keeps the search', () async {
      bloc.emit(const RecordLoaded(records: [], searchQuery: 'coffee'));
      await applyCategoryFilter();

      filteredRecords.add([
        _testRecord(id: 'filtered-2'),
        _testRecord(id: 'filtered-1'),
      ]);
      await settle();

      final loaded = bloc.state as RecordLoaded;
      expect(loaded.records.map((r) => r.id), ['filtered-2', 'filtered-1']);
      expect(loaded.searchQuery, 'coffee');
      expect(loaded.filterCategoryIds, ['cat-1']);
    });

    test('after load more, an update keeps every loaded row', () async {
      final firstPage = List.generate(50, (i) => _testRecord(id: 'rec-$i'));
      final secondPage = List.generate(
        50,
        (i) => _testRecord(id: 'rec-${50 + i}'),
      );
      when(
        () => mockRepo.getFilteredRecords(any()),
      ).thenAnswer((_) async => Right(secondPage));
      bloc.emit(
        RecordLoaded(
          records: firstPage,
          total: 50,
          hasMore: true,
          filterCategoryIds: const ['cat-1'],
        ),
      );

      bloc.add(const LoadMoreRecords());
      await settle();
      filteredRecords.add([
        _testRecord(id: 'new'),
        ...firstPage,
        ...secondPage.take(49),
      ]);
      await settle();

      final watched = verify(
        () => mockRepo.watchFilteredRecords(captureAny()),
      ).captured.cast<RecordFilter>();
      expect(watched.last.limit, 100);
      final loaded = bloc.state as RecordLoaded;
      expect(loaded.records, hasLength(100));
      expect(loaded.hasMore, isTrue);
    });

    test('clearing the filters follows every record again', () async {
      when(
        () => mockGetRecords.call(any()),
      ).thenAnswer((_) async => Right([_testRecord()]));
      await applyCategoryFilter();

      bloc.add(const ClearFilters());
      await settle();
      allRecords.add([_testRecord(id: 'any-category')]);
      await settle();

      final loaded = bloc.state as RecordLoaded;
      expect(loaded.records.map((r) => r.id), ['any-category']);
      expect(loaded.filterCategoryIds, isNull);
    });

    test('a failing live query shows the storage error', () async {
      await applyCategoryFilter();

      filteredRecords.addError(Exception('disk I/O error'));
      await settle();

      expect(
        bloc.state,
        isA<RecordError>().having(
          (e) => e.message,
          'message',
          t.common.errors.storage,
        ),
      );
    });
  });

  group('ApplyFilters', () {
    test('emits RecordLoading then RecordLoaded with filter fields', () async {
      final records = [_testRecord(id: 'filtered-1')];

      when(
        () => mockRepo.getFilteredRecords(any()),
      ).thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ApplyFilters(categoryIds: ['cat-1'], recordType: 'OUT'));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<RecordLoading>());
      expect(states[1], isA<RecordLoaded>());
      final loaded = states[1] as RecordLoaded;
      expect(loaded.records.length, 1);
      expect(loaded.records.first.id, 'filtered-1');
      expect(loaded.filterCategoryIds, ['cat-1']);
      expect(loaded.filterRecordType, 'OUT');
    });

    test('preserves searchQuery from previous state', () async {
      final records = [_testRecord()];

      when(
        () => mockRepo.getFilteredRecords(any()),
      ).thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(RecordLoaded(records: [], searchQuery: 'coffee'));
      bloc.add(const ApplyFilters());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.searchQuery, 'coffee');
    });

    test('emits RecordError on repository failure', () async {
      when(
        () => mockRepo.getFilteredRecords(any()),
      ).thenAnswer((_) async => const Left(CacheFailure(message: 'DB error')));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ApplyFilters());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      expect(states[0], isA<RecordLoading>());
      expect(states[1], isA<RecordError>());
      expect((states[1] as RecordError).message, t.common.errors.storage);
    });
  });

  group('ClearFilters', () {
    test('restarts stream and emits records', () async {
      final records = [_testRecord()];

      when(
        () => mockGetRecords.call(any()),
      ).thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ClearFilters());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().first;
      expect(loaded.records.length, 1);
      expect(loaded.filterStartDate, isNull);
      expect(loaded.filterEndDate, isNull);
      expect(loaded.filterCategoryIds, isNull);
      expect(loaded.filterRecordType, isNull);
    });
  });

  group('LoadMoreRecords with filters', () {
    test('calls getFilteredRecords when filters active', () async {
      final firstPage = List.generate(50, (i) => _testRecord(id: 'rec-$i'));
      final secondPage = [_testRecord(id: 'rec-50')];

      when(
        () => mockRepo.getFilteredRecords(any()),
      ).thenAnswer((_) async => Right(secondPage));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(
        RecordLoaded(
          records: firstPage,
          total: 50,
          hasMore: true,
          filterCategoryIds: ['cat-1'],
        ),
      );

      bloc.add(const LoadMoreRecords());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.records.length, 51);
      expect(loaded.filterCategoryIds, ['cat-1']);

      final captured = verify(
        () => mockRepo.getFilteredRecords(captureAny()),
      ).captured;

      expect(captured.length, 1);
      final filter = captured.first as RecordFilter;
      expect(filter.categoryIds, ['cat-1']);
      expect(filter.limit, 50);
      expect(filter.offset, 50);
    });

    test('calls getRecords when no filters active', () async {
      final firstPage = List.generate(50, (i) => _testRecord(id: 'rec-$i'));
      final secondPage = [_testRecord(id: 'rec-50')];

      when(
        () => mockGetRecords.call(any()),
      ).thenAnswer((_) async => Right(secondPage));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(RecordLoaded(records: firstPage, total: 50, hasMore: true));

      bloc.add(const LoadMoreRecords());

      await Future<void>.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.records.length, 51);
    });
  });
}
