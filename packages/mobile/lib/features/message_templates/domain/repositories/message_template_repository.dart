import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/message_source.dart';
import '../entities/expense_template.dart';

abstract class MessageTemplateRepository {
  Future<Either<Failure, List<MessageSource>>> getMessageSources();
  Future<Either<Failure, MessageSource>> saveMessageSource(
    MessageSource source,
  );
  Future<Either<Failure, Unit>> deleteMessageSource(String id);
  Stream<List<MessageSource>> watchMessageSources();

  Future<Either<Failure, List<ExpenseTemplate>>> getTemplatesForSource(
    String sourceId,
  );
  Future<Either<Failure, List<ExpenseTemplate>>> getAllTemplates();
  Future<Either<Failure, ExpenseTemplate>> saveTemplate(
    ExpenseTemplate template,
  );
  Future<Either<Failure, Unit>> deleteTemplate(String id);
  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId);
}
