import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_records.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';

import '../../../../support/factories/record_factory.dart';

class _MockGetRecords extends Mock implements GetRecords {}

class _MockAddRecord extends Mock implements AddRecord {}

class _MockUpdateRecord extends Mock implements UpdateRecord {}

class _MockRecordRepository extends Mock implements RecordRepository {}

void main() {
  late _MockRecordRepository repository;
  late _MockAddRecord addRecord;
  late RecordBloc bloc;
  final coffee = makeRecord(id: 'rec-1', description: 'Coffee');
  final lunch = makeRecord(id: 'rec-2', description: 'Lunch');
  final taxi = makeRecord(id: 'rec-3', description: 'Taxi');

  setUpAll(() {
    registerFallbackValue(<Record>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(coffee);
  });

  setUp(() {
    repository = _MockRecordRepository();
    addRecord = _MockAddRecord();
    when(() => repository.deleteRecords(any())).thenAnswer(
      (i) async => Right((i.positionalArguments.first as List<String>).toSet()),
    );
    when(
      () => repository.addRecordsBatch(any()),
    ).thenAnswer((_) async => const Right(unit));
    bloc = RecordBloc(
      getRecords: _MockGetRecords(),
      addRecord: addRecord,
      updateRecord: _MockUpdateRecord(),
      recordRepository: repository,
    );
  });

  tearDown(() => bloc.close());

  Future<void> settle() => pumpEventQueue();

  test('deletes all selected ids in one call and emits nothing', () async {
    final states = <RecordState>[];
    final sub = bloc.stream.listen(states.add);
    addTearDown(sub.cancel);

    bloc.add(DeleteRecordsEvent([coffee, lunch, taxi]));
    await settle();

    verify(
      () => repository.deleteRecords(['rec-1', 'rec-2', 'rec-3']),
    ).called(1);
    expect(states, isEmpty);
  });

  test(
    'undo restores only the records the delete removed, in one batch',
    () async {
      when(
        () => repository.deleteRecords(any()),
      ).thenAnswer((_) async => const Right({'rec-1', 'rec-3'}));

      bloc
        ..add(DeleteRecordsEvent([coffee, lunch, taxi]))
        ..add(const RestoreDeletedRecords());
      await settle();

      verify(() => repository.addRecordsBatch([coffee, taxi])).called(1);
      verifyNever(() => addRecord(any()));
    },
  );

  test('a failed delete emits RecordError and undo restores nothing', () async {
    when(
      () => repository.deleteRecords(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk full')));

    bloc.add(DeleteRecordsEvent([coffee]));
    await settle();
    expect(bloc.state, isA<RecordError>());

    bloc.add(const RestoreDeletedRecords());
    await settle();
    verifyNever(() => repository.addRecordsBatch(any()));
  });

  test('an undo sent mid-delete waits for the delete to finish', () async {
    final gate = Completer<Either<CacheFailure, Set<String>>>();
    when(() => repository.deleteRecords(any())).thenAnswer((_) => gate.future);

    bloc
      ..add(DeleteRecordsEvent([coffee, lunch]))
      ..add(const RestoreDeletedRecords());
    await settle();
    verifyNever(() => repository.addRecordsBatch(any()));

    gate.complete(const Right({'rec-1', 'rec-2'}));
    await settle();

    verify(() => repository.addRecordsBatch([coffee, lunch])).called(1);
  });

  test('a second undo restores nothing', () async {
    bloc
      ..add(DeleteRecordsEvent([coffee]))
      ..add(const RestoreDeletedRecords())
      ..add(const RestoreDeletedRecords());
    await settle();

    verify(() => repository.addRecordsBatch(any())).called(1);
  });
}
