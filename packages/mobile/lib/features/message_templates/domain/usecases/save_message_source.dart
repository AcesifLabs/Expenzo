import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/message_source.dart';
import '../repositories/message_template_repository.dart';

class SaveMessageSource implements UseCase<MessageSource, MessageSource> {
  final MessageTemplateRepository repository;

  SaveMessageSource(this.repository);

  /// Returns [Right(T)] on success, [Left(Failure)] on failure.
  @override
  Future<Either<Failure, MessageSource>> call(MessageSource source) {
    return repository.saveMessageSource(source);
  }
}
