import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/create_records_from_parsed_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/parsed_transaction_factory.dart';

class _MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late _MockRecordRepository repository;

  setUp(() {
    repository = _MockRecordRepository();
    when(
      () => repository.getExistingSourceIds(any()),
    ).thenAnswer((_) async => const Right(<String>{}));
    when(
      () => repository.addRecordsBatch(any()),
    ).thenAnswer((_) async => const Right(unit));
  });

  test('messages without a usable amount never become 0 records', () async {
    final result = await CreateRecordsFromParsedList(repository)([
      makeParsedTransaction(sourceId: 'a', amount: 250),
      // The factory fills a missing amount, so build this one by hand.
      const ParsedTransaction(
        rawMessage: 'Your balance is low',
        sourceType: 'sms',
        sourceId: 'b',
        confidenceScore: 0.9,
        parseFailed: false,
      ),
      makeParsedTransaction(sourceId: 'c', amount: 0),
    ]);

    final saved =
        verify(() => repository.addRecordsBatch(captureAny())).captured.single
            as List<Record>;
    expect(saved.map((r) => r.sourceId), ['a']);
    expect(saved.single.amount, -250);
    expect(result.getOrElse(() => throw StateError('failed')).createdCount, 1);
  });
}
