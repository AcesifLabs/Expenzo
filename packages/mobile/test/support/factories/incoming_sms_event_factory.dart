import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';

/// Creates an [IncomingSmsEvent] for tests. All params optional with deterministic defaults.
IncomingSmsEvent makeIncomingSmsEvent({
  String? address,
  String? body,
  DateTime? receivedAt,
}) {
  return IncomingSmsEvent(
    address: address ?? '+1234567890',
    body: body ?? 'Your account was debited \$50.00',
    receivedAt: receivedAt ?? DateTime(2024, 6, 15, 14, 30),
  );
}
