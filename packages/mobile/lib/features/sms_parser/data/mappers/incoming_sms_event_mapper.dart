import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';

IncomingSmsEvent mapIncomingSmsEventPayload(Map<dynamic, dynamic> payload) {
  final address = (payload['address'] ?? payload['sender'] ?? '').toString();
  final body = (payload['body'] ?? payload['message'] ?? '').toString();

  final rawTimestamp =
      payload['receivedAtMs'] ??
      payload['timestamp'] ??
      payload['date'] ??
      payload['receivedAt'];

  final receivedAt = _resolveTimestamp(rawTimestamp);

  return IncomingSmsEvent(address: address, body: body, receivedAt: receivedAt);
}

DateTime _resolveTimestamp(dynamic value) {
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  if (value is String) {
    final numeric = int.tryParse(value);
    if (numeric != null) {
      return DateTime.fromMillisecondsSinceEpoch(numeric, isUtc: true);
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed.toUtc();
    }
  }

  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
