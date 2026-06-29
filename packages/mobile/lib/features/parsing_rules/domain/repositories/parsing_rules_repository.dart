import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import '../entities/parsing_rule.dart';

/// Repository for managing SMS parsing rules.
abstract class ParsingRulesRepository {
  /// Retrieves all parsing rules, optionally filtered by [sourceType] and [isEnabled].
  ///
  /// Returns [Right(List<ParsingRule>)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, List<ParsingRule>>> getRules({
    SourceType? sourceType,
    bool? isEnabled,
  });

  /// Retrieves a parsing rule by its [id].
  ///
  /// Returns [Right(ParsingRule)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, ParsingRule>> getRuleById(String id);

  /// Creates a new [rule].
  ///
  /// Returns [Right(ParsingRule)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, ParsingRule>> createRule(ParsingRule rule);

  /// Updates an existing [rule].
  ///
  /// Returns [Right(ParsingRule)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, ParsingRule>> updateRule(ParsingRule rule);

  /// Deletes a rule by [id].
  ///
  /// Returns [Right(unit)] on success, [Left(Failure)] on failure.
  Future<Either<Failure, Unit>> deleteRule(String id);

  /// Watches for changes to the parsing rules list.
  Stream<List<ParsingRule>> watchRules();
}
