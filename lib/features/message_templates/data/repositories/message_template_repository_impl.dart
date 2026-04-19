import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_template.dart';
import '../../domain/entities/message_source.dart';
import '../../domain/repositories/message_template_repository.dart';
import '../datasources/message_template_local_datasource.dart';

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message})
    : super(errorCode: 'DB_ERROR');
}

class MessageTemplateRepositoryImpl implements MessageTemplateRepository {
  final MessageTemplateLocalDatasource localDatasource;

  MessageTemplateRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<MessageSource>>> getMessageSources() async {
    try {
      final sources = await localDatasource.getMessageSources();
      return Right(sources);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MessageSource>> saveMessageSource(
    MessageSource source,
  ) async {
    try {
      final saved = await localDatasource.saveMessageSource(source);
      return Right(saved);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessageSource(String id) async {
    try {
      await localDatasource.deleteMessageSource(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<MessageSource>> watchMessageSources() {
    return localDatasource.watchMessageSources();
  }

  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getTemplatesForSource(
    String sourceId,
  ) async {
    try {
      final templates = await localDatasource.getTemplatesForSource(sourceId);
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseTemplate>>> getAllTemplates() async {
    try {
      final templates = await localDatasource.getAllTemplates();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseTemplate>> saveTemplate(
    ExpenseTemplate template,
  ) async {
    try {
      final saved = await localDatasource.saveTemplate(template);
      return Right(saved);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTemplate(String id) async {
    try {
      await localDatasource.deleteTemplate(id);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<ExpenseTemplate>> watchTemplatesForSource(String sourceId) {
    return localDatasource.watchTemplatesForSource(sourceId);
  }
}
