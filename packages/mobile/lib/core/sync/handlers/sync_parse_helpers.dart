/// Safe parsing helpers for sync handler fromSyncPayload methods.
/// Handles malformed remote payloads without throwing.
library;

double parseSyncAmount(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

DateTime parseSyncDate(dynamic value) {
  if (value is DateTime) return value.toLocal();
  if (value is String) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return DateTime.now().toUtc();
    }
  }
  return DateTime.now().toUtc();
}

String parseSyncString(dynamic value, [String fallback = '']) {
  if (value is String) return value;
  if (value != null) return value.toString();
  return fallback;
}
