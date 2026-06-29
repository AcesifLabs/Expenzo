import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';
import 'token_storage.dart';
import '../sync/connectivity_service.dart';
import '../di/injection_container.dart' as di;

class ApiClient {
  Dio dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'bypass-tunnel-reminder': 'true',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void updateBaseUrl() {
    dio.options.baseUrl = ApiConstants.baseUrl;
  }

  void _setupInterceptors() {
    dio.interceptors.addAll([_AuthInterceptor(dio), _LoggingInterceptor()]);
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('AuthInterceptor.onRequest error: $e');
    } finally {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final connectivity = di.getIt<ConnectivityService>();
        if (!await connectivity.checkNow()) {
          debugPrint('AuthInterceptor: Offline, skipping token refresh');
          handler.next(err);

          return;
        }
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final firebaseToken = await firebaseUser.getIdToken(true);
          final authDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
          final response = await authDio.post(
            ApiConstants.login,
            data: {'firebaseToken': firebaseToken},
          );
          final newJwt = response.data['accessToken'];
          await TokenStorage.saveToken(newJwt);
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newJwt';
          final retryResponse = await _dio.fetch(opts);
          handler.resolve(retryResponse);

          return;
        }
      } catch (e, s) {
        debugPrint('Error: $e\n$s');
        debugPrint('Token refresh failed: $e');
        await TokenStorage.clearAll();
      }
    }
    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API] ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] Error: ${err.message}');
    handler.next(err);
  }
}
