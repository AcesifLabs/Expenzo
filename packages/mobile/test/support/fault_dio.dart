import 'package:dio/dio.dart';
import 'package:expense_tracker/core/api/api_client.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mocktail/mocktail.dart';

class FaultApiClient extends Mock implements ApiClient {}

enum NetworkFault { serverError, emptyBody, html, timeout, unauthorized }

class _AnyRequest extends HttpRequestMatcher {
  const _AnyRequest();

  @override
  bool matches(RequestOptions ongoingRequest, Request matcher) => true;
}

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
