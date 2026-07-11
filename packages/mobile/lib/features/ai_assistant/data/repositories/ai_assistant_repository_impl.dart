import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../datasources/groq_datasource.dart';
import '../../domain/repositories/ai_assistant_repository.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  final GroqDataSource dataSource;

  const AiAssistantRepositoryImpl({required this.dataSource});

  @override
  Stream<Either<Failure, String>> sendMessageStream({
    required String message,
    required String context,
  }) {
    try {
      return dataSource
          .streamChat(systemPrompt: context, userMessage: message)
          .map<Either<Failure, String>>((token) => Right(token))
          .handleError((error) {
            return Left(ServerFailure(message: error.toString()));
          });
    } catch (e) {
      return Stream.value(Left(ServerFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, String>> sendMessage({
    required String message,
    required String context,
  }) async {
    try {
      final buffer = StringBuffer();
      await for (final token in dataSource.streamChat(
        systemPrompt: context,
        userMessage: message,
      )) {
        buffer.write(token);
      }

      return Right(buffer.toString());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
