import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class MockLocalDatasource extends Mock implements RecordLocalDatasource {}

class MockRemoteDatasource extends Mock implements RecordRemoteDatasource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  setUpAll(() {
    registerFallbackValue(RecordFilter());
    registerFallbackValue(RemoteRecordQuery());
  });

  late MockLocalDatasource mockLocal;
  late MockRemoteDatasource mockRemote;
  late MockConnectivityService mockConnectivity;
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

  setUp(() {
    mockLocal = MockLocalDatasource();
    mockRemote = MockRemoteDatasource();
    mockConnectivity = MockConnectivityService();

    repository = RecordRepositoryImpl(
      localDatasource: mockLocal,
      remoteDatasource: mockRemote,
      connectivity: mockConnectivity,
    );
  });

  RecordFilter emptyFilter() => const RecordFilter();

  group('RecordRepositoryImpl.getFilteredRecords', () {
    group('when online', () {
      setUp(() {
        when(() => mockConnectivity.checkNow()).thenAnswer((_) async => true);
      });

      test('calls remote datasource and returns records', () async {
        when(
          () => mockRemote.getRecords(any()),
        ).thenAnswer((_) async => RecordRemoteResponse(data: [testRecord]));

        final result = await repository.getFilteredRecords(emptyFilter());
        final records = result.getOrElse(
          () => throw 'Expected Right, got Left',
        );

        expect(records.length, 1);
        expect(records.first.id, 'rec-1');
      });

      test(
        'passes filter params to remote datasource with UTC conversion',
        () async {
          final captured = <RemoteRecordQuery>[];
          when(() => mockRemote.getRecords(any())).thenAnswer((invocation) {
            captured.add(
              invocation.positionalArguments[0] as RemoteRecordQuery,
            );
            return Future.value(RecordRemoteResponse(data: [testRecord]));
          });

          await repository.getFilteredRecords(
            RecordFilter(
              limit: 50,
              startDate: DateTime.utc(2024, 1, 1),
              endDate: DateTime.utc(2024, 12, 31),
              categoryIds: ['cat-1', 'cat-2'],
              recordType: 'OUT',
            ),
          );

          expect(captured.length, 1);
          expect(captured.first.limit, 50);
          expect(captured.first.startDate, '2024-01-01T00:00:00.000Z');
          expect(captured.first.endDate, '2024-12-31T00:00:00.000Z');
          expect(captured.first.categoryIds, ['cat-1', 'cat-2']);
          expect(captured.first.recordType, 'OUT');
        },
      );

      test('returns ServerFailure on ServerException', () async {
        when(() => mockRemote.getRecords(any())).thenThrow(
          const ServerException(message: 'API error', statusCode: 500),
        );

        final result = await repository.getFilteredRecords(emptyFilter());

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'API error');
        }, (_) => fail('Expected Left, got Right'));
      });
    });

    group('when offline', () {
      setUp(() {
        when(() => mockConnectivity.checkNow()).thenAnswer((_) async => false);
      });

      test('calls local datasource and returns records', () async {
        when(
          () => mockLocal.getFilteredRecords(any()),
        ).thenAnswer((_) async => [testRecord]);

        final result = await repository.getFilteredRecords(emptyFilter());
        final records = result.getOrElse(
          () => throw 'Expected Right, got Left',
        );

        expect(records.length, 1);
        expect(records.first.id, 'rec-1');

        verify(
          () => mockLocal.getFilteredRecords(const RecordFilter()),
        ).called(1);
      });

      test('returns CacheFailure on CacheException', () async {
        when(
          () => mockLocal.getFilteredRecords(any()),
        ).thenThrow(const CacheException(message: 'DB error'));

        final result = await repository.getFilteredRecords(emptyFilter());

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'DB error');
        }, (_) => fail('Expected Left, got Right'));
      });
    });
  });
}
