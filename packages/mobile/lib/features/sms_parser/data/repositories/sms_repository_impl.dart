import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../../domain/entities/sms_message.dart';
import '../../domain/repositories/sms_repository.dart';
import '../datasources/sms_local_datasource.dart';

class SmsRepositoryImpl implements SmsRepository {
  final SmsLocalDatasource _datasource;

  SmsRepositoryImpl({required SmsLocalDatasource datasource})
    : _datasource = datasource;

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<SmsMessage>>> querySms({
    DateTime? since,
    String? sender,
  }) async {
    try {
      List<SmsMessage> messages;

      if (sender != null) {
        messages = await _datasource.getSmsFromAddress(sender);
        if (since != null) {
          messages = messages.where((m) => m.date.isAfter(since)).toList();
        }
      } else if (since != null) {
        messages = await _datasource.getSmsFromDateRange(since, DateTime.now());
      } else {
        messages = await _datasource.getAllSms();
      }

      return Right(messages);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      return Left(CacheFailure(message: 'Failed to query SMS: $e'));
    }
  }

  @override
  Stream<List<SmsMessage>> watchNewMessages() {
    return _pollMessages();
  }

  Stream<List<SmsMessage>> _pollMessages() async* {
    List<SmsMessage> lastBatch = [];
    while (true) {
      try {
        final messages = await _datasource.getSmsBatched(start: 0, count: 50);

        if (messages.isNotEmpty && !_listsEqual(messages, lastBatch)) {
          lastBatch = messages;
          yield messages;
        }
      } catch (e, s) {
        debugPrint('Error: $e\n$s');
        debugPrint('SmsRepositoryImpl: Poll failed: $e');
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  bool _listsEqual(List<SmsMessage> a, List<SmsMessage> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }
}
