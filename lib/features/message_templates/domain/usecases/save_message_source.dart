import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/message_source.dart';
import '../repositories/message_template_repository.dart';

class SaveMessageSource implements UseCase<MessageSource, MessageSource> {
  final MessageTemplateRepository repository;

  SaveMessageSource(this.repository);

  @override
  Future<Either<Failure, MessageSource>> call(MessageSource source) {
    return repository.saveMessageSource(source);
  }
}
