import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/expense_template.dart';
import '../repositories/message_template_repository.dart';

class SaveTemplate implements UseCase<ExpenseTemplate, ExpenseTemplate> {
  final MessageTemplateRepository repository;

  SaveTemplate(this.repository);

  @override
  Future<Either<Failure, ExpenseTemplate>> call(ExpenseTemplate template) {
    return repository.saveTemplate(template);
  }
}
