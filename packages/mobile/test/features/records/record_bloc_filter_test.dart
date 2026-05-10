import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

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

/// Helper: collect all emitted states until bloc closes, then verify.
Future<List<RecordState>> collectStates(RecordBloc bloc, {int count = 3}) {
  final states = <RecordState>[];
  final sub = bloc.stream.listen(states.add);
  return Future.delayed(const Duration(milliseconds: 100), () {
    sub.cancel();
    return states;
  });
}

void main() {
  late MockRecordRepository mockRepo;
  late MockGetRecords mockGetRecords;
  late MockAddRecord mockAddRecord;
  late MockUpdateRecord mockUpdateRecord;
  late MockDeleteRecord mockDeleteRecord;
  late RecordBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeGetRecordsParams());
  });

  setUp(() {
    mockRepo = MockRecordRepository();
    mockGetRecords = MockGetRecords();
    mockAddRecord = MockAddRecord();
    mockUpdateRecord = MockUpdateRecord();
    mockDeleteRecord = MockDeleteRecord();

    when(() => mockRepo.watchRecords(limit: any(named: 'limit')))
        .thenAnswer((_) => const Stream.empty());

    bloc = RecordBloc(
      getRecords: mockGetRecords,
      addRecord: mockAddRecord,
      updateRecord: mockUpdateRecord,
      deleteRecord: mockDeleteRecord,
      recordRepository: mockRepo,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ApplyFilters', () {
    test('emits RecordLoading then RecordLoaded with filter fields', () async {
      final records = [_testRecord(id: 'filtered-1')];

      when(() => mockRepo.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ApplyFilters(
        categoryIds: ['cat-1'],
        recordType: 'OUT',
      ));

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 100));
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

      when(() => mockRepo.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(RecordLoaded(records: [], searchQuery: 'coffee'));
      bloc.add(const ApplyFilters());

      await Future.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.searchQuery, 'coffee');
    });

    test('emits RecordError on repository failure', () async {
      when(() => mockRepo.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: any(named: 'limit'),
          )).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error')),
      );

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ApplyFilters());

      await Future.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      expect(states[0], isA<RecordLoading>());
      expect(states[1], isA<RecordError>());
      expect((states[1] as RecordError).message, 'Server error');
    });
  });

  group('ClearFilters', () {
    test('restarts stream and emits records', () async {
      final records = [_testRecord()];

      when(() => mockGetRecords.call(any()))
          .thenAnswer((_) async => Right(records));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ClearFilters());

      await Future.delayed(const Duration(milliseconds: 100));
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

      when(() => mockRepo.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: 50,
            offset: 50,
          )).thenAnswer((_) async => Right(secondPage));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(RecordLoaded(
        records: firstPage,
        total: 50,
        hasMore: true,
        filterCategoryIds: ['cat-1'],
      ));

      bloc.add(const LoadMoreRecords());

      await Future.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.records.length, 51);
      expect(loaded.filterCategoryIds, ['cat-1']);

      verify(() => mockRepo.getFilteredRecords(
            startDate: null,
            endDate: null,
            categoryIds: ['cat-1'],
            recordType: null,
            limit: 50,
            offset: 50,
          )).called(1);
    });

    test('calls getRecords when no filters active', () async {
      final firstPage = List.generate(50, (i) => _testRecord(id: 'rec-$i'));
      final secondPage = [_testRecord(id: 'rec-50')];

      when(() => mockGetRecords.call(any()))
          .thenAnswer((_) async => Right(secondPage));

      final states = <RecordState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.emit(RecordLoaded(
        records: firstPage,
        total: 50,
        hasMore: true,
      ));

      bloc.add(const LoadMoreRecords());

      await Future.delayed(const Duration(milliseconds: 100));
      sub.cancel();

      final loaded = states.whereType<RecordLoaded>().last;
      expect(loaded.records.length, 51);
    });
  });
}
