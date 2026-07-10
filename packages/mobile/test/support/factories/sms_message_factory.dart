import 'package:expense_tracker/features/sms_parser/domain/entities/sms_message.dart';

/// Creates an [SmsMessage] for tests. All params optional with deterministic defaults.
SmsMessage makeSmsMessage({
  String? id,
  String? address,
  String? body,
  DateTime? date,
  bool? read,
  SmsType? type,
}) {
  return SmsMessage(
    id: id ?? 'sms-0001',
    address: address ?? '+1234567890',
    body: body ?? 'Your account was debited \$50.00',
    date: date ?? DateTime(2024, 6, 15, 14, 30),
    read: read ?? true,
    type: type ?? SmsType.received,
  );
}
