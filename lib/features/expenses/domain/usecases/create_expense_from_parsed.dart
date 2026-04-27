import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import '../entities/expense.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../repositories/expense_repository.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

class CreateExpenseFromParsed extends UseCase<Expense?, ParsedTransaction> {
  final ExpenseRepository repository;

  CreateExpenseFromParsed(this.repository);

  @override
  Future<Either<Failure, Expense?>> call(ParsedTransaction parsed) async {
    // Check if already exists by sourceId
    final existsResult = await repository.expenseExistsBySourceId(
      parsed.sourceId,
    );

    return existsResult.fold((failure) => Left(failure), (alreadyExists) async {
      if (alreadyExists) {
        // Skip silently - return success with null
        return const Right(null);
      }

      // Create new expense
      final expense = Expense(
        amount: parsed.amount ?? 0,
        description: parsed.description ?? parsed.rawMessage,
        date: parsed.date ?? DateTime.now(),
        categoryId: parsed.categoryId != null
            ? int.tryParse(parsed.categoryId!)
            : null,
        source: parsed.sourceType == 'sms'
            ? ExpenseSource.sms
            : ExpenseSource.email,
        sourceId: parsed.sourceId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return repository.addExpense(expense);
    });
  }
}
