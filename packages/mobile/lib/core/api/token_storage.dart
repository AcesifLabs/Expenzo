import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logger/app_logger.dart';
import '../sync/sync_outcome_store.dart';

class TokenStorage {
  static const _tokenKey = 'jwt_access_token';
  static const _lastSyncKey = 'last_sync_at';
  static const _isFirstSyncKey = 'is_first_sync';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() => _read(_tokenKey);

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

  static Future<String?> getLastSyncAt() => _read(_lastSyncKey);

  static Future<bool> isFirstSync() async {
    final value = await _read(_isFirstSyncKey);

    return value == null || value == 'true';
  }

  static Future<void> markFirstSyncDone() async {
    await _storage.write(key: _isFirstSyncKey, value: 'false');
  }

  static Future<void> clearSyncState() async {
    await _storage.delete(key: _lastSyncKey);
    await _storage.delete(key: _isFirstSyncKey);
    await SyncOutcomeStore.clear();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e, s) {
      appLogger.error('Secure storage could not read $key', e, s);

      return null;
    }
  }
}
