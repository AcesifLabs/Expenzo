import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/sms_message.dart';

/// Repository for querying and watching SMS messages.
abstract class SmsRepository {
  /// Queries SMS messages, optionally filtered by [since] date and [sender].
  ///
  /// Returns [Right(List<SmsMessage>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<SmsMessage>>> querySms({
    DateTime? since,
    String? sender,
  });

  /// Streams newly received SMS messages in real time.
  Stream<List<SmsMessage>> watchNewMessages();
}
