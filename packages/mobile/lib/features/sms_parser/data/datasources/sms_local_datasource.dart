import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as fsms;
import '../../domain/entities/sms_message.dart';

abstract class SmsLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<List<SmsMessage>> getAllSms();
  Future<List<SmsMessage>> getSmsFromDateRange(DateTime start, DateTime end);
  Future<List<SmsMessage>> getSmsFromAddress(String address);
  Future<List<SmsMessage>> getSmsBatched({
    int start = 0,
    int count = 100,
    String? address,
  });
}

class SmsLocalDatasourceImpl implements SmsLocalDatasource {
  final fsms.SmsQuery _smsQuery;

  SmsLocalDatasourceImpl({required fsms.SmsQuery smsQuery})
    : _smsQuery = smsQuery;

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<SmsMessage>> getAllSms() async {
    try {
      final messages = await _smsQuery.getAllSms;

      return messages.map(_mapToEntity).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      return [];
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<SmsMessage>> getSmsFromDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final messages = await _smsQuery.getAllSms;

      return messages
          .where((m) {
            final date = m.date;

            return date != null && date.isAfter(start) && date.isBefore(end);
          })
          .map(_mapToEntity)
          .toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      return [];
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<SmsMessage>> getSmsFromAddress(String address) async {
    try {
      final messages = await _smsQuery.querySms(address: address);

      return messages.map(_mapToEntity).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      return [];
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<SmsMessage>> getSmsBatched({
    int start = 0,
    int count = 100,
    String? address,
  }) async {
    try {
      final messages = await _smsQuery.querySms(
        start: start,
        count: count,
        address: address,
        kinds: [fsms.SmsQueryKind.inbox],
      );

      return messages.map(_mapToEntity).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      return [];
    }
  }

  SmsMessage _mapToEntity(fsms.SmsMessage message) {
    final date = message.date ?? DateTime.now();

    return SmsMessage(
      id: message.id?.toString() ?? '',
      address: message.address ?? '',
      body: message.body ?? '',
      date: date,
      read: message.read ?? false,
      type: _mapSmsKind(message.kind),
    );
  }

  SmsType _mapSmsKind(fsms.SmsMessageKind? kind) {
    switch (kind) {
      case fsms.SmsMessageKind.received:
        return SmsType.received;
      case fsms.SmsMessageKind.sent:
        return SmsType.sent;
      case fsms.SmsMessageKind.draft:
        return SmsType.draft;
      default:
        return SmsType.received;
    }
  }
}
