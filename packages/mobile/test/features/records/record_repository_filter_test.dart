import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class MockLocalDatasource extends Mock implements RecordLocalDatasource {}

void main() {
  setUpAll(() => registerFallbackValue(const RecordFilter()));

  late MockLocalDatasource mockLocal;
  late RecordRepositoryImpl repository;

  final testRecord = Record(
    id: 'rec-1',
    amount: 100.0,
    description: 'Test',
    date: DateTime(2024, 1, 15),
    categoryId: 'cat-1',
    recordType: RecordType.expense,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  const filter = RecordFilter(
    categoryIds: ['cat-1'],
    recordType: 'OUT',
    limit: 50,
    offset: 50,
  );

  setUp(() {
    mockLocal = MockLocalDatasource();
    repository = RecordRepositoryImpl(localDatasource: mockLocal);
  });

  group('RecordRepositoryImpl.getFilteredRecords', () {
    test('reads the filter, offset included, from this device', () async {
      when(
        () => mockLocal.getFilteredRecords(any()),
      ).thenAnswer((_) async => [testRecord]);

      final result = await repository.getFilteredRecords(filter);

      expect(result.getOrElse(() => fail('Expected records')), [testRecord]);
      verify(() => mockLocal.getFilteredRecords(filter)).called(1);
    });

    test('returns CacheFailure on CacheException', () async {
      when(
        () => mockLocal.getFilteredRecords(any()),
      ).thenThrow(const CacheException(message: 'DB error'));

      final result = await repository.getFilteredRecords(filter);

      result.fold((failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.message, 'DB error');
      }, (_) => fail('Expected Left, got Right'));
    });
  });

  test('watchFilteredRecords follows this device\'s records', () {
    when(
      () => mockLocal.watchFilteredRecords(filter),
    ).thenAnswer((_) => Stream.value([testRecord]));

    expect(repository.watchFilteredRecords(filter), emits([testRecord]));
  });
}
