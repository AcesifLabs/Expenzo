import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../../domain/repositories/message_template_repository.dart';
import '../datasources/message_template_local_datasource.dart';

class MessageTemplateRepositoryImpl implements MessageTemplateRepository {
  final MessageTemplateLocalDatasource localDatasource;

  MessageTemplateRepositoryImpl(this.localDatasource);

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<MessageSource>>> getMessageSources() async {
    try {
      final sources = await localDatasource.getMessageSources();

      return Right(sources);
    } catch (e, s) {
      appLogger.error('Error getting message sources', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, MessageSource>> saveMessageSource(
    MessageSource source,
  ) async {
    try {
      final saved = await localDatasource.saveMessageSource(source);

      return Right(saved);
    } catch (e, s) {
      appLogger.error('Error saving message source', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Unit>> deleteMessageSource(String id) async {
    try {
      await localDatasource.deleteMessageSource(id);

      return const Right(unit);
    } catch (e, s) {
      appLogger.error('Error deleting message source', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MessageSource>> watchMessageSources() {
    return localDatasource.watchMessageSources();
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getTemplatesForSource(
    String sourceId,
  ) async {
    try {
      final templates = await localDatasource.getTemplatesForSource(sourceId);

      return Right(templates);
    } catch (e, s) {
      appLogger.error('Error getting templates for source', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getAllTemplates() async {
    try {
      final templates = await localDatasource.getAllTemplates();

      return Right(templates);
    } catch (e, s) {
      appLogger.error('Error getting all templates', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, ExpenseTemplate>> saveTemplate(
    ExpenseTemplate template,
  ) async {
    try {
      final saved = await localDatasource.saveTemplate(template);

      return Right(saved);
    } catch (e, s) {
      appLogger.error('Error saving template', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Returns Left(Failure) on error.
  @override
  Future<Either<Failure, Unit>> deleteTemplate(String id) async {
    try {
      await localDatasource.deleteTemplate(id);

      return const Right(unit);
    } catch (e, s) {
      appLogger.error('Error deleting template', e, s);
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId) {
    return localDatasource.watchTemplatesForSource(sourceId);
  }
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message})
    : super(errorCode: 'DB_ERROR');
}
