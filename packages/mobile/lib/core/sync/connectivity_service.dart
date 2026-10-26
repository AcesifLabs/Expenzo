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

      _isOnline = _isHealthy(response);

      return _isOnline;
    } catch (e) {
      _isOnline = false;

      return false;
    }
  }
}
