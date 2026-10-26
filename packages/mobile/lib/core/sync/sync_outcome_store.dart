import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncOutcomeStore {
  static const _successKey = 'last_successful_sync_at';
  static const _failureKey = 'last_failed_sync_at';
  static const _failureCountKey = 'consecutive_sync_failures';
  static final _storage = FlutterSecureStorage();

  static Future<void> recordSyncSuccess(DateTime time) async {
    await _storage.write(
      key: _successKey,
      value: time.toUtc().toIso8601String(),
    );
    await _storage.delete(key: _failureKey);
    await _storage.delete(key: _failureCountKey);
  }

  static Future<void> recordSyncFailure(DateTime time) async {
    final raw = await _storage.read(key: _failureCountKey);
    final count = int.tryParse(raw ?? '') ?? 0;
    await _storage.write(
      key: _failureKey,
      value: time.toUtc().toIso8601String(),
    );
    await _storage.write(key: _failureCountKey, value: '${count + 1}');
  }

  static Future<DateTime?> getLastSuccessfulSyncAt() => _readTime(_successKey);

  static Future<DateTime?> getLastFailedSyncAt() => _readTime(_failureKey);

  static Future<int> getConsecutiveSyncFailures() async {
    final raw = await _storage.read(key: _failureCountKey);

    return int.tryParse(raw ?? '') ?? 0;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _successKey);
    await _storage.delete(key: _failureKey);
    await _storage.delete(key: _failureCountKey);
  }

  static Future<DateTime?> _readTime(String key) async {
    final value = await _storage.read(key: key);

    return value == null ? null : DateTime.tryParse(value)?.toLocal();
  }
}
