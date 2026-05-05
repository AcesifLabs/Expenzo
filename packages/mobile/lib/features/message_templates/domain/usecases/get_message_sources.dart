import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/message_source.dart';
import '../repositories/message_template_repository.dart';

class GetMessageSources implements UseCase<List<MessageSource>, NoParams> {
  final MessageTemplateRepository repository;

  GetMessageSources(this.repository);

  @override
  Future<Either<Failure, List<MessageSource>>> call(NoParams params) {
    return repository.getMessageSources();
  }
}
