import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';

abstract class AiAssistantRepository {
  Stream<Either<Failure, String>> sendMessageStream({
    required String message,
    required String context,
  });

  Future<Either<Failure, String>> sendMessage({
    required String message,
    required String context,
  });
}
