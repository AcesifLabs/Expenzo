import 'dart:async';
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

  /// Single-flight guard for token refresh.
  /// When non-null, concurrent 401s await this future instead of each
  /// independently triggering a refresh.
  Completer<String?>? _refreshCompleter;

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
    } catch (e) {
      debugPrint('AuthInterceptor.onRequest error: ${e.runtimeType}');
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
          handler.next(err);

          return;
        }

        // Single-flight: if a refresh is already in progress, await it
        final newJwt = await _refreshToken();

        if (newJwt != null) {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newJwt';
          final retryResponse = await _dio.fetch(opts);
          handler.resolve(retryResponse);

          return;
        }
      } catch (e) {
        debugPrint('Token refresh failed: ${e.runtimeType}');
        await TokenStorage.clearAll();
      }
    }
    handler.next(err);
  }

  /// Performs a single-flight token refresh.
  /// Returns the new JWT string, or null if refresh fails.
  Future<String?> _refreshToken() {
    // If a refresh is already in flight, await it
    final existingCompleter = _refreshCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    // Start a new refresh
    final completer = Completer<String?>();
    _refreshCompleter = completer;

    _doRefresh()
        .then((token) {
          completer.complete(token);
          _refreshCompleter = null;
        })
        .catchError((Object e) {
          debugPrint('Token refresh error: ${e.runtimeType}');
          completer.complete(null);
          _refreshCompleter = null;
        });

    return completer.future;
  }

  Future<String?> _doRefresh() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final firebaseToken = await firebaseUser.getIdToken(true);
    final authDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    final response = await authDio.post(
      ApiConstants.login,
      data: {'firebaseToken': firebaseToken},
    );
    final newJwt = response.data['accessToken'];
    if (newJwt is! String || newJwt.isEmpty) {
      return null;
    }
    await TokenStorage.saveToken(newJwt);

    return newJwt;
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
