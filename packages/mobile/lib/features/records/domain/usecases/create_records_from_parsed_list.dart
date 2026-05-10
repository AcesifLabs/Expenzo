import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';
import '../../domain/entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../../domain/repositories/record_repository.dart';

class CreateRecordsFromParsedList
    extends UseCase<CreateRecordsResult, List<ParsedTransaction>> {
  final RecordRepository repository;

  CreateRecordsFromParsedList(this.repository);

  @override
  Future<Either<Failure, CreateRecordsResult>> call(
    List<ParsedTransaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      return const Right(
        CreateRecordsResult(createdCount: 0, skippedDuplicates: 0, errors: []),
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
          CreateRecordsResult(
            createdCount: 0,
            skippedDuplicates: skippedDuplicates,
            errors: [],
          ),
        );
      }

      // 3. Map to Record entities (Parsed are always OUT/Expense)
      final now = DateTime.now();
      final recordsToCreate = toCreate
          .map(
            (parsed) => Record(
              amount: -(parsed.amount?.abs() ?? 0),
              description: parsed.description ?? parsed.rawMessage,
              date: parsed.date ?? now,
              categoryId: parsed.categoryId,
              source: parsed.sourceType == AppSourceType.sms
                  ? ExpenseSource.sms
                  : ExpenseSource.email,
              sourceId: parsed.sourceId,
              recordType: RecordType.expense,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList();

      // 4. Batch create records
      final batchResult = await repository.addRecordsBatch(recordsToCreate);

      return batchResult.fold((failure) => Left(failure), (_) {
        createdCount = recordsToCreate.length;
        return Right(
          CreateRecordsResult(
            createdCount: createdCount,
            skippedDuplicates: skippedDuplicates,
            errors: errors,
          ),
        );
      });
    });
  }
}

class CreateRecordsResult {
  final int createdCount;
  final int skippedDuplicates;
  final List<String> errors;

  const CreateRecordsResult({
    required this.createdCount,
    required this.skippedDuplicates,
    required this.errors,
  });

  int get totalProcessed => createdCount + skippedDuplicates + errors.length;
}
