import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../entities/expense_template.dart';
import '../repositories/message_template_repository.dart';

class GetTemplatesForSource implements UseCase<List<ExpenseTemplate>, String> {
  final MessageTemplateRepository repository;

  GetTemplatesForSource(this.repository);

  @override
  Future<Either<Failure, List<ExpenseTemplate>>> call(String sourceId) {
    return repository.getTemplatesForSource(sourceId);
  }
}
