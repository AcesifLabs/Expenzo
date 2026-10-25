import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

/// An [ApiClient] to hand a [faultyDio].
class FaultApiClient extends Mock implements ApiClient {}

/// Ways a server or network can fail a request.
enum NetworkFault {
  /// HTTP 500 with an error body.
  serverError,

  /// HTTP 200 with an empty JSON object.
  emptyBody,

  /// HTTP 200 with an HTML page, as a captive portal sends.
  html,

  /// No answer before the connection timeout.
  timeout,

  /// HTTP 401, as when the session expired and can't be renewed.
  unauthorized,
}

class _AnyRequest extends HttpRequestMatcher {
  const _AnyRequest();

  @override
  bool matches(RequestOptions ongoingRequest, Request matcher) => true;
}

/// A [Dio] whose every request fails with [fault].
Dio faultyDio(NetworkFault fault) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
  DioAdapter(dio: dio, matcher: const _AnyRequest()).onGet('/', (server) {
    switch (fault) {
      case NetworkFault.serverError:
        server.reply(500, {'message': 'Internal server error'});
      case NetworkFault.emptyBody:
        server.reply(200, <String, dynamic>{});
      case NetworkFault.html:
        server.reply(
          200,
          '<html><body>Sign in to the Wi-Fi</body></html>',
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        );
      case NetworkFault.timeout:
        server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        );
      case NetworkFault.unauthorized:
        server.reply(401, {'message': 'Unauthorized'});
    }
  });

  return dio;
}
