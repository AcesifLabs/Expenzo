import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../domain/entities/expense.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../../domain/repositories/expense_repository.dart';

class CreateExpensesFromParsedList
    extends UseCase<CreateExpensesResult, List<ParsedTransaction>> {
  final ExpenseRepository repository;

  CreateExpensesFromParsedList(this.repository);

  @override
  Future<Either<Failure, CreateExpensesResult>> call(
    List<ParsedTransaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return const Right(
        CreateExpensesResult(createdCount: 0, skippedDuplicates: 0, errors: []),
      );
    }

    int createdCount = 0;
    int skippedDuplicates = 0;
    final List<String> errors = [];

    // 1. Batch check all sourceIds in ONE query
    final allSourceIds = transactions.map((t) => t.sourceId).toList();
    final existingResult = await repository.getExistingSourceIds(allSourceIds);

    return existingResult.fold((failure) => Left(failure), (existingIds) async {
      // 2. Filter to only non-duplicate transactions
      final toCreate = transactions
          .where((t) => !existingIds.contains(t.sourceId))
          .toList();
      skippedDuplicates = transactions.length - toCreate.length;

      if (toCreate.isEmpty) {
        return Right(
          CreateExpensesResult(
            createdCount: 0,
            skippedDuplicates: skippedDuplicates,
            errors: [],
          ),
        );
      }

      // 3. Map to Expense entities
      final now = DateTime.now();
      final expensesToCreate = toCreate
          .map(
            (parsed) => Expense(
              amount: parsed.amount ?? 0,
              description: parsed.description ?? parsed.rawMessage,
              date: parsed.date ?? now,
              categoryId: parsed.categoryId != null
                  ? int.tryParse(parsed.categoryId!)
                  : null,
              source: parsed.sourceType == AppSourceType.sms
                  ? ExpenseSource.sms
                  : ExpenseSource.email,
              sourceId: parsed.sourceId,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList();

      // 4. Batch create expenses
      final batchResult = await repository.addExpensesBatch(expensesToCreate);

      return batchResult.fold((failure) => Left(failure), (_) {
        createdCount = expensesToCreate.length;
        return Right(
          CreateExpensesResult(
            createdCount: createdCount,
            skippedDuplicates: skippedDuplicates,
            errors: errors,
          ),
        );
      });
    });
  }
}

class CreateExpensesResult {
  final int createdCount;
  final int skippedDuplicates;
  final List<String> errors;

  const CreateExpensesResult({
    required this.createdCount,
    required this.skippedDuplicates,
    required this.errors,
  });

  int get totalProcessed => createdCount + skippedDuplicates + errors.length;
}
