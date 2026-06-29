import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';

class MockRecordRepository extends Mock implements RecordRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('Record Use Case Tests', () {
    late MockRecordRepository mockRepository;
    late MockCategoryRepository mockCategoryRepository;
    late GetRecords getRecordsUseCase;
    late AddRecord addRecordUseCase;
    late UpdateRecord updateRecordUseCase;
    late DeleteRecord deleteRecordUseCase;

    final now = DateTime.now();
    final testRecord = Record(
      id: '1',
      amount: 100.50,
      description: 'Lunch at restaurant',
      date: now,
      categoryId: '1',
      source: ExpenseSource.manual,
      sourceId: null,
      recordType: RecordType.expense,
      createdAt: now,
      updatedAt: now,
    );

    final testRecords = [
      testRecord,
      Record(
        id: '2',
        amount: 50.00,
        description: 'Bus fare',
        date: now,
        categoryId: '2',
        source: ExpenseSource.manual,
        sourceId: null,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUpAll(() {
      registerFallbackValue(testRecord);
      registerFallbackValue(DateTime.now());
    });

    setUp(() {
      mockRepository = MockRecordRepository();
      mockCategoryRepository = MockCategoryRepository();
      getRecordsUseCase = GetRecords(mockRepository);
      addRecordUseCase = AddRecord(mockRepository, mockCategoryRepository);
      updateRecordUseCase = UpdateRecord(mockRepository);
      deleteRecordUseCase = DeleteRecord(mockRepository);
    });

    test('getRecords returns list of records', () async {
      when(
        () => mockRepository.getRecords(
          dateRange: any(named: 'dateRange'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right(testRecords));

      final result = await getRecordsUseCase(const GetRecordsParams());

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (records) {
        expect(records.length, 2);
        expect(records.first.amount, 100.50);
      });
    });

    test('addRecord adds and returns record and increments usage', () async {
      when(
        () => mockRepository.addRecord(any()),
      ).thenAnswer((_) async => Right(testRecord));
      when(
        () => mockCategoryRepository.incrementUsageCount(any()),
      ).thenAnswer((_) async => const Right(unit));

      final result = await addRecordUseCase(testRecord);

      expect(result.isRight(), true);
      verify(() => mockRepository.addRecord(testRecord)).called(1);
      verify(
        () =>
            mockCategoryRepository.incrementUsageCount(testRecord.categoryId!),
      ).called(1);
    });

    test('updateRecord updates and returns record', () async {
      when(
        () => mockRepository.updateRecord(any()),
      ).thenAnswer((_) async => Right(testRecord));

      final result = await updateRecordUseCase(testRecord);

      expect(result.isRight(), true);
      verify(() => mockRepository.updateRecord(testRecord)).called(1);
    });

    test('deleteRecord deletes successfully', () async {
      when(
        () => mockRepository.deleteRecord(any()),
      ).thenAnswer((_) async => const Right(unit));

      await deleteRecordUseCase('1');

      verify(() => mockRepository.deleteRecord('1')).called(1);
    });

    test('getRecordById returns record', () async {
      when(
        () => mockRepository.getRecordById(any()),
      ).thenAnswer((_) async => Right(testRecord));

      final result = await mockRepository.getRecordById('1');

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (record) {
        expect(record, testRecord);
        expect(record.id, '1');
      });
    });

    test('recordExistsBySourceId returns false', () async {
      when(
        () => mockRepository.recordExistsBySourceId(any()),
      ).thenAnswer((_) async => const Right(false));

      final result = await mockRepository.recordExistsBySourceId('sms_123');

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (exists) => expect(exists, false),
      );
    });
  });

  group('Record Entity Tests', () {
    test('should create record with required fields', () {
      final now = DateTime.now();
      final record = Record(
        amount: 100.50,
        description: 'Test record',
        date: now,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.amount, 100.50);
      expect(record.description, 'Test record');
      expect(record.source, ExpenseSource.manual);
      expect(record.categoryId, null);
      expect(record.sourceId, null);
    });

    test('should create record with all fields', () {
      final now = DateTime.now();
      final record = Record(
        id: '1',
        amount: 50.00,
        description: 'Bus fare',
        date: now,
        categoryId: '2',
        source: ExpenseSource.sms,
        sourceId: 'sms_123',
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.id, '1');
      expect(record.amount, 50.00);
      expect(record.description, 'Bus fare');
      expect(record.categoryId, '2');
      expect(record.source, ExpenseSource.sms);
      expect(record.sourceId, 'sms_123');
    });

    test('should detect record from scan', () {
      final now = DateTime.now();
      final manualRecord = Record(
        amount: 100,
        description: 'Manual',
        date: now,
        source: ExpenseSource.manual,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );
      final smsRecord = Record(
        amount: 100,
        description: 'SMS',
        date: now,
        source: ExpenseSource.sms,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(manualRecord.isFromScan, false);
      expect(smsRecord.isFromScan, true);
    });

    test('should allow negative amount', () {
      final now = DateTime.now();
      final record = Record(
        amount: -50.00,
        description: 'Refund',
        date: now,
        source: ExpenseSource.manual,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.amount, -50.00);
    });

    test('should allow future date for planned records', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 7));
      final record = Record(
        amount: 100,
        description: 'Planned record',
        date: futureDate,
        source: ExpenseSource.manual,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.date.isAfter(now), true);
    });

    test('should support unlimited description length', () {
      final now = DateTime.now();
      final longDescription = 'A' * 10000;
      final record = Record(
        amount: 100,
        description: longDescription,
        date: now,
        source: ExpenseSource.manual,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      expect(record.description.length, 10000);
    });

    test('should copy record with updated fields', () {
      final now = DateTime.now();
      final original = Record(
        id: '1',
        amount: 100,
        description: 'Original',
        date: now,
        source: ExpenseSource.manual,
        recordType: RecordType.expense,
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(amount: 200, description: 'Updated');

      expect(updated.id, '1');
      expect(updated.amount, 200);
      expect(updated.description, 'Updated');
    });
  });

  group('ExpenseSource Tests', () {
    test('should have correct display names', () {
      expect(ExpenseSource.manual.displayName, 'Manual');
      expect(ExpenseSource.sms.displayName, 'SMS');
      expect(ExpenseSource.email.displayName, 'Email');
      expect(ExpenseSource.recurring.displayName, 'Recurring');
    });

    test('should have correct icons', () {
      expect(ExpenseSource.manual.icon, '✏️');
      expect(ExpenseSource.sms.icon, '💬');
      expect(ExpenseSource.email.icon, '📧');
      expect(ExpenseSource.recurring.icon, '🔄');
    });
  });

  group('DateTimeRange Tests', () {
    test('should create date range with start and end', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);

      final range = DateTimeRange(start: start, end: end);

      expect(range.start, start);
      expect(range.end, end);
    });
  });
}
