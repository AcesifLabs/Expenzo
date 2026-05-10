import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'jwt_access_token';
  static const _lastSyncKey = 'last_sync_at';
  static const _isFirstSyncKey = 'is_first_sync';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveLastSyncAt(String isoTime) async {
    await _storage.write(key: _lastSyncKey, value: isoTime);
  }

  static Future<String?> getLastSyncAt() async {
    return _storage.read(key: _lastSyncKey);
  }

  static Future<bool> isFirstSync() async {
    final value = await _storage.read(key: _isFirstSyncKey);
    return value == null || value == 'true';
  }

  static Future<void> markFirstSyncDone() async {
    await _storage.write(key: _isFirstSyncKey, value: 'false');
  }

  static Future<void> clearSyncState() async {
    await _storage.delete(key: _lastSyncKey);
    await _storage.delete(key: _isFirstSyncKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
