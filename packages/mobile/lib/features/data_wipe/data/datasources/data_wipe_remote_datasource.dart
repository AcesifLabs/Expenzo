import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/api/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';

abstract class DataWipeRemoteDatasource {
  /// Deletes every row the signed-in account synced. Idempotent.
  ///
  /// Throws: [AuthException] on 401, [NetworkException] when the server
  /// can't be reached, [ServerException] otherwise.
  Future<void> clearSyncedData();
}

class DataWipeRemoteDatasourceImpl implements DataWipeRemoteDatasource {
  final ApiClient apiClient;

  static const _connectionErrors = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  };

  const DataWipeRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<void> clearSyncedData() async {
    try {
      await apiClient.dio.delete<Object?>(ApiConstants.syncClear);
    } on DioException catch (e) {
      throw _exceptionFor(e);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  static Exception _exceptionFor(DioException e) {
    final message = e.message ?? e.type.name;
    final status = e.response?.statusCode;
    if (status == 401) return AuthException(message: message);
    if (_connectionErrors.contains(e.type)) {
      return NetworkException(message: message);
    }

    return ServerException(message: message, statusCode: status);
  }
}
