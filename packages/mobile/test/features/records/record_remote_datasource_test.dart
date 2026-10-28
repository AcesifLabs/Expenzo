import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/records/data/datasources/record_remote_datasource.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

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

  group('RecordRemoteDatasourceImpl.fillMissingBudgetLinks', () {
    test('posts id and budgetId pairs to the budget-links endpoint', () async {
      when(
        () => mockDio.post<Object?>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiConstants.recordBudgetLinks),
          data: {'updated': 2},
          statusCode: 200,
        ),
      );

      await datasource.fillMissingBudgetLinks([
        (id: 'rec-1', budgetId: 'bud-1'),
        (id: 'rec-2', budgetId: 'bud-2'),
      ]);

      verify(
        () => mockDio.post<Object?>(
          ApiConstants.recordBudgetLinks,
          data: {
            'links': [
              {'id': 'rec-1', 'budgetId': 'bud-1'},
              {'id': 'rec-2', 'budgetId': 'bud-2'},
            ],
          },
        ),
      ).called(1);
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.post<Object?>(any(), data: any(named: 'data')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiConstants.recordBudgetLinks),
        ),
      );

      expect(
        () => datasource.fillMissingBudgetLinks([
          (id: 'rec-1', budgetId: 'bud-1'),
        ]),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
