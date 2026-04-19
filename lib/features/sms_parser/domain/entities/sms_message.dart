import 'package:equatable/equatable.dart';

class SmsMessage extends Equatable {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  final bool read;
  final SmsType type;

  const SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.read,
    required this.type,
  });

  @override
  List<Object?> get props => [id, address, body, date, read, type];
}

enum SmsType { received, sent, draft }

SmsType smsTypeFromInt(int type) {
  switch (type) {
    case 1:
      return SmsType.received;
    case 2:
      return SmsType.sent;
    default:
      return SmsType.received;
  }
}
