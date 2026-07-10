import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as fsms;
import 'package:expense_tracker/core/logger/app_logger.dart';
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
      appLogger.error('SMS local datasource error', e, s);

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

      // Run filtering in a background isolate to avoid blocking the UI
      return compute(
        _filterByDateRange,
        _DateRangeFilterParams(messages, start, end),
      );
    } catch (e, s) {
      appLogger.error('SMS local datasource error', e, s);

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
      appLogger.error('SMS local datasource error', e, s);

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
      appLogger.error('SMS local datasource error', e, s);

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

/// Parameters for background isolate date-range filtering.
class _DateRangeFilterParams {
  final List<fsms.SmsMessage> messages;
  final DateTime start;
  final DateTime end;

  const _DateRangeFilterParams(this.messages, this.start, this.end);
}

/// Runs in a background isolate via [compute].
List<SmsMessage> _filterByDateRange(_DateRangeFilterParams params) {
  return params.messages
      .where((m) {
        final date = m.date;

        return date != null &&
            date.isAfter(params.start) &&
            date.isBefore(params.end);
      })
      .map(
        (m) => SmsMessage(
          id: m.id?.toString() ?? '',
          address: m.address ?? '',
          body: m.body ?? '',
          date: m.date ?? DateTime.now(),
          read: m.read ?? false,
          type: _mapSmsKindStatic(m.kind),
        ),
      )
      .toList();
}

SmsType _mapSmsKindStatic(fsms.SmsMessageKind? kind) {
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
