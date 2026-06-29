import 'package:equatable/equatable.dart';

class SmsMessage extends Equatable {
  final String id;
  final String address;
  final String body;
  final DateTime date;
  final bool read;
  final SmsType type;

  @override
  List<Object?> get props => [id, address, body, date, read, type];

  const SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    required this.read,
    required this.type,
  });
}

enum SmsType { received, sent, draft }
