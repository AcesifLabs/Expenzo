import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/usecase.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import 'create_expense_from_parsed.dart';

class CreateExpensesFromParsedList
    extends UseCase<CreateExpensesResult, List<ParsedTransaction>> {
  final CreateExpenseFromParsed createExpenseFromParsed;

  CreateExpensesFromParsedList(this.createExpenseFromParsed);

  @override
  Future<Either<Failure, CreateExpensesResult>> call(
    List<ParsedTransaction> transactions,
  ) async {
    int createdCount = 0;
    int skippedDuplicates = 0;
    List<String> errors = [];

    for (final parsed in transactions) {
      final result = await createExpenseFromParsed(parsed);

      result.fold(
        (failure) {
          errors.add('${parsed.sourceId}: ${failure.message}');
        },
        (expense) {
          if (expense != null) {
            createdCount++;
          } else {
            skippedDuplicates++;
          }
        },
      );
    }

    return Right(
      CreateExpensesResult(
        createdCount: createdCount,
        skippedDuplicates: skippedDuplicates,
        errors: errors,
      ),
    );
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
