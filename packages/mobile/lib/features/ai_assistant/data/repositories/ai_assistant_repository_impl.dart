import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/network_error.dart';
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
          .transform(
            StreamTransformer.fromHandlers(
              handleError: (Object error, StackTrace _, sink) =>
                  sink.add(Left(failureFromNetworkOrServer(error))),
            ),
          );
    } catch (e) {
      return Stream.value(Left(failureFromNetworkOrServer(e)));
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
      return Left(failureFromNetworkOrServer(e));
    }
  }
}
