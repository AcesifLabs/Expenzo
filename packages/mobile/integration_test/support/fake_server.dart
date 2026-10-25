import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_constants.dart';

/// Answers the sync endpoints and the health check as a working server
/// would, so end-to-end tests don't need the backend or a sign-in.
class FakeSyncServer extends Interceptor {
  /// Changes the app pushed, in order.
  final List<Map<String, dynamic>> pushed = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    if (path.endsWith(ApiConstants.syncPull)) {
      return handler.resolve(
        _ok(options, {
          'serverTime': DateTime.now().toUtc().toIso8601String(),
          'changes': <Object>[],
        }),
      );
    }
    if (path.endsWith(ApiConstants.syncPush)) {
      final changes = ((options.data as Map)['changes'] as List)
          .cast<Map<String, dynamic>>();
      pushed.addAll(changes);

      return handler.resolve(
        _ok(options, {
          'results': [
            for (final change in changes)
              {'id': change['id'], 'status': 'success'},
          ],
        }),
      );
    }
    if (path.endsWith(ApiConstants.health)) {
      return handler.resolve(
        _ok(options, {ApiConstants.healthStatusKey: ApiConstants.healthOk}),
      );
    }
    handler.next(options);
  }

  Response<Object?> _ok(RequestOptions options, Object data) =>
      Response(requestOptions: options, statusCode: 200, data: data);
}
