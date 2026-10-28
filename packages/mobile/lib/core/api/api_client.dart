import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';
import 'token_storage.dart';
import '../sync/connectivity_service.dart';
import '../logger/app_logger.dart';
import '../di/injection_container.dart' as di;
import 'fault_injection_interceptor.dart';

bool isDeletedUserResponse(Response<dynamic>? response) {
  final data = response?.data;

  return response?.statusCode == 401 &&
      data is Map &&
      data['message'] == ApiConstants.deletedUserMessage;
}

class TokenRefreshRejected implements Exception {
  const TokenRefreshRejected();
}

class ApiClient {
  Dio dio;

  @visibleForTesting
  static Future<String?> Function()? refreshOverride;

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
    dio.interceptors.addAll([
      ?FaultInjectionInterceptor.fromEnvironment(),
      _AuthInterceptor(dio),
      _LoggingInterceptor(),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  static const _retriedKey = 'retriedAfterRefresh';

  final Dio _dio;

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
    } catch (e, s) {
      appLogger.error('AuthInterceptor.onRequest error', e, s);
    } finally {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (isDeletedUserResponse(err.response)) {
      for (final step in [TokenStorage.clearAll, _signOutFirebase]) {
        try {
          await step();
        } catch (e, s) {
          appLogger.error('AuthInterceptor: sign-out step failed', e, s);
        }
      }
      handler.next(err);

      return;
    }
    final options = err.requestOptions;

    if (err.response?.statusCode == 401 && options.extra[_retriedKey] != true) {
      final newJwt = await _refreshWhenOnline(options);
      if (newJwt != null) {
        options.headers['Authorization'] = 'Bearer $newJwt';
        options.extra[_retriedKey] = true;
        try {
          handler.resolve(await _dio.fetch(options));
        } on DioException catch (retryError) {
          handler.next(retryError);
        }

        return;
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshWhenOnline(RequestOptions options) async {
    try {
      final current = await TokenStorage.getToken();
      if (current != null &&
          current.isNotEmpty &&
          options.headers['Authorization'] != 'Bearer $current') {
        return current;
      }
      if (!await di.getIt<ConnectivityService>().checkNow()) return null;

      return await _refreshToken();
    } catch (e, s) {
      appLogger.error('Token refresh failed', e, s);

      return null;
    }
  }

  static Future<void> _signOutFirebase() => FirebaseAuth.instance.signOut();

  Future<String?> _refreshToken() {
    final existingCompleter = _refreshCompleter;
    if (existingCompleter != null) {
      return existingCompleter.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    (ApiClient.refreshOverride ?? _doRefresh)()
        .then((token) {
          completer.complete(token);
          _refreshCompleter = null;
        })
        .catchError((Object e, StackTrace s) async {
          if (e is TokenRefreshRejected) {
            await TokenStorage.deleteToken();
          } else {
            appLogger.error('Token refresh error', e, s);
          }
          completer.complete(null);
          _refreshCompleter = null;
        });

    return completer.future;
  }

  Future<String?> _doRefresh() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final firebaseToken = await firebaseUser.getIdToken(true);

    final authDio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );
    final Response<dynamic> response;
    try {
      response = await authDio.post(
        ApiConstants.login,
        data: {'firebaseToken': firebaseToken},
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) throw const TokenRefreshRejected();
      rethrow;
    }
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
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('[API] ${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] Error: ${err.message}');
    handler.next(err);
  }
}
