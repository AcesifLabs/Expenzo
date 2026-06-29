import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final ApiClient _apiClient;
  bool _isOnline = false;

  bool get isOnline => _isOnline;

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged
      .handleError((Object error, StackTrace stack) {
        debugPrint('[ConnectivityService] stream error: $error');
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
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('[ConnectivityService] checkNow error: $e');

      return _isOnline;
    }
  }

  Future<bool> _checkConnectivity(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      _isOnline = false;

      return false;
    }
    try {
      await _apiClient.dio
          .get('/health', options: Options(validateStatus: (_) => true))
          .timeout(const Duration(seconds: 5));
      _isOnline = true;

      return true;
    } catch (e, s) {
      debugPrint('Connectivity error: $e\n$s');
      _isOnline = false;

      return false;
    }
  }
}
