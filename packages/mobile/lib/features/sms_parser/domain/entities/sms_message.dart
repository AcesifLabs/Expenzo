import 'package:equatable/equatable.dart';
import 'sms_type.dart';

export 'sms_type.dart';

class SmsMessage extends Equatable {
  final String id;
  final String address;
  final String body;

  /// When the phone received it.
  final DateTime date;

  /// The time on the message itself (the inbox's `date_sent`), which a
  /// live receipt also reports; null when the inbox doesn't have it.
  final DateTime? sentAt;
  final bool read;
  final SmsType type;

  @override
  List<Object?> get props => [id, address, body, date, sentAt, read, type];

  const SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.date,
    this.sentAt,
    required this.read,
    required this.type,
  });

  SmsMessage copyWith({
    String? id,
    String? address,
    String? body,
    DateTime? date,
    DateTime? sentAt,
    bool? read,
    SmsType? type,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      address: address ?? this.address,
      body: body ?? this.body,
      date: date ?? this.date,
      sentAt: sentAt ?? this.sentAt,
      read: read ?? this.read,
      type: type ?? this.type,
    );
  }
}
