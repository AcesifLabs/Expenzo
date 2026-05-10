import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../repositories/record_repository.dart';
import '../../../parsing_rules/domain/entities/parsed_transaction.dart';

class CreateRecordFromParsed extends UseCase<Record?, ParsedTransaction> {
  final RecordRepository repository;

  CreateRecordFromParsed(this.repository);

  @override
  Future<Either<Failure, Record?>> call(ParsedTransaction parsed) async {
    // Check if already exists by sourceId
    final existsResult = await repository.recordExistsBySourceId(
      parsed.sourceId,
    );

    return existsResult.fold((failure) => Left(failure), (alreadyExists) async {
      if (alreadyExists) {
        // Skip silently - return success with null
        return const Right(null);
      }

      // Create new record (SMS/Email parsed are always OUT/Expense)
      final record = Record(
        amount: -(parsed.amount?.abs() ?? 0),
        description: parsed.description ?? parsed.rawMessage,
        date: parsed.date ?? DateTime.now(),
        categoryId: parsed.categoryId,
        source: parsed.sourceType == 'sms'
            ? ExpenseSource.sms
            : ExpenseSource.email,
        sourceId: parsed.sourceId,
        recordType: RecordType.expense,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return repository.addRecord(record);
    });
  }
}
