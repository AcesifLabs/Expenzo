import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../repositories/ai_assistant_repository.dart';

class SendMessageStream {
  final AiAssistantRepository repository;

  const SendMessageStream({required this.repository});

  Stream<Either<Failure, String>> call({
    required String message,
    required String context,
  }) {
    return repository.sendMessageStream(message: message, context: context);
  }
}
