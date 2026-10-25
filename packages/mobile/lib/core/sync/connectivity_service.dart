import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final ApiClient _apiClient;
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .handleError((Object error, StackTrace stack) {
        _isOnline = false;
      })
      .asyncMap((results) => _checkConnectivity(results));

  ConnectivityService({Connectivity? connectivity, ApiClient? apiClient})
    : _connectivity = connectivity ?? Connectivity(),
      _apiClient = apiClient ?? ApiClient();

  Future<bool> checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();

      return _checkConnectivity(results);
    } catch (e) {
      return _isOnline;
    }
  }

  /// True when the device reports any link (Wi‑Fi, mobile, …). Does not ping
  /// the backend — use this for "you're offline" UI on features that need
  /// the public internet (sign-in, Ask AI, Receipt Scan).
  Future<bool> hasNetworkLink() async {
    try {
      final results = await _connectivity.checkConnectivity();

      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      return false;
    }
  }

  static bool _isHealthy(Response<Object?> response) {
    final status = response.statusCode ?? 0;
    final body = response.data;

    return status >= 200 &&
        status < 300 &&
        body is Map &&
        body[ApiConstants.healthStatusKey] == ApiConstants.healthOk;
  }

  Future<bool> _checkConnectivity(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOnline = false;

      return false;
    }
    try {
      final response = await _apiClient.dio
          .get<Object?>(
            ApiConstants.health,
            options: Options(validateStatus: (_) => true),
          )
          .timeout(const Duration(seconds: 5));
      // Only our backend's answer counts: a captive portal or a proxy also
      // returns 200, with its own page.
      _isOnline = _isHealthy(response);

      return _isOnline;
    } catch (e) {
      _isOnline = false;

      return false;
    }
  }
}
