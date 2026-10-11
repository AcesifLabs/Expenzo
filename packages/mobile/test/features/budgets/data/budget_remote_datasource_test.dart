import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockApiClient apiClient;
  late _MockDio dio;

  setUp(() {
    apiClient = _MockApiClient();
    dio = _MockDio();
    when(() => apiClient.dio).thenReturn(dio);
  });

  test('fillMissingNames posts id and name pairs', () async {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiConstants.budgetNames),
        statusCode: 200,
      ),
    );

    await BudgetRemoteDatasourceImpl(
      apiClient: apiClient,
    ).fillMissingNames([(id: 'b1', name: 'Groceries')]);

    verify(
      () => dio.post<dynamic>(
        ApiConstants.budgetNames,
        data: {
          'names': [
            {'id': 'b1', 'name': 'Groceries'},
          ],
        },
      ),
    ).called(1);
  });

  test('fillMissingNames reports a failed request as ServerException', () {
    when(() => dio.post<dynamic>(any(), data: any(named: 'data'))).thenThrow(
      DioException(requestOptions: RequestOptions(path: '/budgets/names')),
    );

    expect(
      BudgetRemoteDatasourceImpl(
        apiClient: apiClient,
      ).fillMissingNames([(id: 'b1', name: 'Groceries')]),
      throwsA(isA<ServerException>()),
    );
  });
}
