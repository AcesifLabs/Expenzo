import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final ApiClient _apiClient = ApiClient();
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Stream<bool> get onlineStream => _connectivity.onConnectivityChanged.asyncMap((results) => _checkConnectivity(results));

  Future<bool> _checkConnectivity(List<ConnectivityResult> results) async {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) { _isOnline = false; return false; }
    try {
      await _apiClient.dio.get('/health', options: Options(validateStatus: (_) => true)).timeout(const Duration(seconds: 5));
      _isOnline = true; return true;
    } catch (_) { _isOnline = false; return false; }
  }

  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    return _checkConnectivity(results);
  }
}
