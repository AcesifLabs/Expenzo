import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late RecordRemoteDatasourceImpl datasource;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/records'));
    registerFallbackValue(Uri.parse('/records'));
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();

    when(() => mockApiClient.dio).thenReturn(mockDio);

    datasource = RecordRemoteDatasourceImpl(apiClient: mockApiClient);
  });

  group('RecordRemoteDatasourceImpl.getRecords', () {
    test('parses amount from string (PostgreSQL decimal)', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': '42.50',
              'description': 'Coffee',
              'date': '2024-01-15T10:30:00Z',
              'categoryId': 'cat-1',
              'source': 'manual',
              'sourceId': null,
              'recordType': 'OUT',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T12:00:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.length, 1);
      expect(result.data.first.amount, 42.50);
    });

    test('parses amount from number', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 100,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.amount, 100.0);
    });

    test('handles null amount gracefully', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': null,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.amount, 0.0);
    });

    test('parses createdAt and updatedAt from ISO 8601', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'IN',
              'createdAt': '2024-01-15T09:00:00Z',
              'updatedAt': '2024-01-15T11:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.createdAt, DateTime.utc(2024, 1, 15, 9, 0, 0));
      expect(result.data.first.updatedAt, DateTime.utc(2024, 1, 15, 11, 30, 0));
    });

    test('parses source from string to ExpenseSource enum', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'source': 'sms',
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.source, ExpenseSource.sms);
    });

    test('defaults source to manual when null', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'source': null,
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.source, ExpenseSource.manual);
    });

    test('maps recordType IN to RecordType.income', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.recordType, RecordType.income);
    });

    test('maps recordType OUT to RecordType.expense', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'OUT',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': null,
          'total': 1,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.data.first.recordType, RecordType.expense);
    });

    test('throws ServerException on DioException', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/records'),
          message: 'Network error',
        ),
      );

      expect(() => datasource.getRecords(), throwsA(isA<ServerException>()));
    });

    test('returns correct nextCursor and total from response', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '/records'),
        data: {
          'data': [
            {
              'id': 'rec-1',
              'amount': 10,
              'description': 'Test',
              'date': '2024-01-15T10:30:00Z',
              'recordType': 'IN',
              'createdAt': '2024-01-15T10:30:00Z',
              'updatedAt': '2024-01-15T10:30:00Z',
            },
          ],
          'nextCursor': 'cursor-123',
          'total': 100,
        },
        statusCode: 200,
      );

      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => mockResponse);

      final result = await datasource.getRecords();
      expect(result.nextCursor, 'cursor-123');
      expect(result.total, 100);
    });
  });
}
