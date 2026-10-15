import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/data_wipe/data/datasources/data_wipe_remote_datasource.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDio extends Mock implements Dio {}

DioException _error(DioExceptionType type, {int? status}) => DioException(
  requestOptions: RequestOptions(path: ApiConstants.syncClear),
  type: type,
  response: status == null
      ? null
      : Response(
          requestOptions: RequestOptions(path: ApiConstants.syncClear),
          statusCode: status,
        ),
);

void main() {
  late _MockDio dio;
  late DataWipeRemoteDatasourceImpl datasource;

  setUp(() {
    dio = _MockDio();
    final apiClient = _MockApiClient();
    when(() => apiClient.dio).thenReturn(dio);
    datasource = DataWipeRemoteDatasourceImpl(apiClient: apiClient);
  });

  void deleteThrows(Object error) =>
      when(() => dio.delete<dynamic>(any())).thenThrow(error);

  test('calls DELETE /sync/clear', () async {
    when(() => dio.delete<dynamic>(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ApiConstants.syncClear),
        statusCode: 200,
      ),
    );

    await datasource.clearSyncedData();

    verify(() => dio.delete<dynamic>(ApiConstants.syncClear)).called(1);
  });

  test('401 throws AuthException', () {
    deleteThrows(_error(DioExceptionType.badResponse, status: 401));

    expect(datasource.clearSyncedData(), throwsA(isA<AuthException>()));
  });

  test('connection errors throw NetworkException', () async {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      deleteThrows(_error(type));

      await expectLater(
        datasource.clearSyncedData(),
        throwsA(isA<NetworkException>()),
        reason: type.name,
      );
    }
  });

  test('other failures throw ServerException with the status', () async {
    deleteThrows(_error(DioExceptionType.badResponse, status: 503));

    await expectLater(
      datasource.clearSyncedData(),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'statusCode', 503),
      ),
    );

    deleteThrows(StateError('interceptor'));
    await expectLater(
      datasource.clearSyncedData(),
      throwsA(isA<ServerException>()),
    );
  });
}
