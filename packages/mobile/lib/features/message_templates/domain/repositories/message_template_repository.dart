import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/message_source.dart';
import '../entities/expense_template.dart';

/// Repository for managing message sources and expense templates.
abstract class MessageTemplateRepository {
  /// Retrieves all message sources.
  ///
  /// Returns [Right(List<MessageSource>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<MessageSource>>> getMessageSources();

  /// Saves a [source] to the repository.
  ///
  /// Returns [Right(MessageSource)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, MessageSource>> saveMessageSource(
    MessageSource source,
  );

  /// Deletes a message source by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> deleteMessageSource(String id);

  /// Watches for changes to message sources.
  Stream<List<MessageSource>> watchMessageSources();

  /// Retrieves expense templates for a given [sourceId].
  ///
  /// Returns [Right(List<ExpenseTemplate>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<ExpenseTemplate>>> getTemplatesForSource(
    String sourceId,
  );

  /// Retrieves all expense templates.
  ///
  /// Returns [Right(List<ExpenseTemplate>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<ExpenseTemplate>>> getAllTemplates();

  /// Saves a [template] to the repository.
  ///
  /// Returns [Right(ExpenseTemplate)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, ExpenseTemplate>> saveTemplate(
    ExpenseTemplate template,
  );

  /// Deletes a template by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> deleteTemplate(String id);

  /// Watches for changes to templates for a given [sourceId].
  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId);
}
