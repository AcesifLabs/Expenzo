import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/data/datasources/record_local_datasource.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/features/records/data/repositories/record_repository_impl.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class MockLocalDatasource extends Mock implements RecordLocalDatasource {}

class MockRemoteDatasource extends Mock implements RecordRemoteDatasource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
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

  group('RecordRepositoryImpl.getFilteredRecords', () {
    group('when online', () {
      setUp(() {
        when(() => mockConnectivity.checkNow()).thenAnswer((_) async => true);
      });

      test('calls remote datasource and returns records', () async {
        when(
          () => mockRemote.getRecords(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
          ),
        ).thenAnswer((_) async => RecordRemoteResponse(data: [testRecord]));

        final result = await repository.getFilteredRecords();
        final records = result.getOrElse(
          () => throw 'Expected Right, got Left',
        );

        expect(records.length, 1);
        expect(records.first.id, 'rec-1');
      });

      test(
        'passes filter params to remote datasource with UTC conversion',
        () async {
          when(
            () => mockRemote.getRecords(
              limit: 50,
              startDate: '2024-01-01T00:00:00.000Z',
              endDate: '2024-12-31T00:00:00.000Z',
              categoryIds: ['cat-1', 'cat-2'],
              recordType: 'OUT',
            ),
          ).thenAnswer((_) async => RecordRemoteResponse(data: [testRecord]));

          await repository.getFilteredRecords(
            limit: 50,
            startDate: DateTime.utc(2024, 1, 1),
            endDate: DateTime.utc(2024, 12, 31),
            categoryIds: ['cat-1', 'cat-2'],
            recordType: 'OUT',
          );

          verify(
            () => mockRemote.getRecords(
              limit: 50,
              startDate: '2024-01-01T00:00:00.000Z',
              endDate: '2024-12-31T00:00:00.000Z',
              categoryIds: ['cat-1', 'cat-2'],
              recordType: 'OUT',
            ),
          ).called(1);
        },
      );

      test('returns ServerFailure on ServerException', () async {
        when(
          () => mockRemote.getRecords(
            limit: any(named: 'limit'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
          ),
        ).thenThrow(
          const ServerException(message: 'API error', statusCode: 500),
        );

        final result = await repository.getFilteredRecords();

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
          () => mockLocal.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [testRecord]);

        final result = await repository.getFilteredRecords();
        final records = result.getOrElse(
          () => throw 'Expected Right, got Left',
        );

        expect(records.length, 1);
        expect(records.first.id, 'rec-1');

        verify(
          () => mockLocal.getFilteredRecords(
            startDate: null,
            endDate: null,
            categoryIds: null,
            recordType: null,
            limit: null,
            offset: null,
          ),
        ).called(1);
      });

      test('returns CacheFailure on CacheException', () async {
        when(
          () => mockLocal.getFilteredRecords(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryIds: any(named: 'categoryIds'),
            recordType: any(named: 'recordType'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const CacheException(message: 'DB error'));

        final result = await repository.getFilteredRecords();

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, 'DB error');
        }, (_) => fail('Expected Left, got Right'));
      });
    });
  });
}
