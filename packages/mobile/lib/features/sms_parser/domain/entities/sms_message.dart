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

  SmsMessage copyWith({
    String? id,
    String? address,
    String? body,
    DateTime? date,
    bool? read,
    SmsType? type,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      address: address ?? this.address,
      body: body ?? this.body,
      date: date ?? this.date,
      read: read ?? this.read,
      type: type ?? this.type,
    );
  }
}

enum SmsType { received, sent, draft }
