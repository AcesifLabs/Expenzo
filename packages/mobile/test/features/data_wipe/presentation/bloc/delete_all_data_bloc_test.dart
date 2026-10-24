import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/domain/repositories/data_wipe_repository.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/delete_all_data.dart';
import 'package:expense_tracker/features/data_wipe/domain/usecases/get_local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_bloc.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_event.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class _MockGetSummary extends Mock implements GetLocalDataSummary {}

class _MockRepository extends Mock implements DataWipeRepository {}

class _MockDeleteAllData extends Mock implements DeleteAllData {}

void main() {
  const summary = LocalDataSummary(
    transactions: 3,
    budgets: 1,
    categories: 18,
    recurring: 0,
    smsRules: 2,
  );

  late _MockGetSummary getSummary;
  late _MockRepository repository;
  late _MockDeleteAllData deleteAllData;
  late DeleteAllDataBloc bloc;

  setUpAll(() => registerFallbackValue(NoParams()));

  setUp(() {
    getSummary = _MockGetSummary();
    repository = _MockRepository();
    deleteAllData = _MockDeleteAllData();
    when(() => repository.isSignedIn()).thenAnswer((_) async => true);
    when(() => getSummary(any())).thenAnswer((_) async => const Right(summary));
    bloc = DeleteAllDataBloc(
      getSummary: getSummary,
      repository: repository,
      deleteAllData: deleteAllData,
    );
  });

  tearDown(() => bloc.close());

  Future<void> readyWith(String text) async {
    bloc
      ..add(const DeleteAllDataStarted())
      ..add(DeleteConfirmationChanged(text));
    await pumpEventQueue();
  }

  TypeMatcher<DeleteAllDataState> hasStatus(DeleteAllDataStatus status) =>
      isA<DeleteAllDataState>().having((s) => s.status, 'status', status);

  test('start loads the summary and the signed-in flag', () async {
    bloc.add(const DeleteAllDataStarted());
    await pumpEventQueue();

    expect(bloc.state.status, DeleteAllDataStatus.ready);
    expect(bloc.state.summary, summary);
    expect(bloc.state.isSignedIn, isTrue);
  });

  group('family admin line', () {
    DeleteAllDataBloc blocWith({bool Function()? isFamilyAdmin}) =>
        DeleteAllDataBloc(
          getSummary: getSummary,
          repository: repository,
          deleteAllData: deleteAllData,
          isFamilyAdmin: isFamilyAdmin,
        );

    Future<bool> startedAsAdmin(DeleteAllDataBloc subject) async {
      addTearDown(subject.close);
      subject.add(const DeleteAllDataStarted());
      await pumpEventQueue();

      return subject.state.isFamilyAdmin;
    }

    test('a signed-in family admin gets it', () async {
      expect(await startedAsAdmin(blocWith(isFamilyAdmin: () => true)), isTrue);
    });

    test('signed out never gets it', () async {
      when(() => repository.isSignedIn()).thenAnswer((_) async => false);

      expect(
        await startedAsAdmin(blocWith(isFamilyAdmin: () => true)),
        isFalse,
      );
    });

    test('without the callback there is no line', () async {
      expect(await startedAsAdmin(blocWith()), isFalse);
    });
  });

  test('a summary failure still reaches ready', () async {
    when(
      () => getSummary(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));

    bloc.add(const DeleteAllDataStarted());
    await pumpEventQueue();

    expect(bloc.state.status, DeleteAllDataStatus.ready);
    expect(bloc.state.summary, isNull);
  });

  test('lower-case delete does not enable deleting', () async {
    await readyWith('delete');

    expect(bloc.state.canDelete, isFalse);
  });

  test('DELETE with surrounding spaces enables deleting', () async {
    await readyWith(' DELETE ');

    expect(bloc.state.canDelete, isTrue);
  });

  test('a request without the confirmation does nothing', () async {
    await readyWith('DELET');

    bloc.add(const DeleteAllRequested());
    await pumpEventQueue();

    verifyNever(() => deleteAllData(any()));
  });

  test('success emits deleting then done, once on a double tap', () async {
    final result = Completer<Either<Failure, Unit>>();
    when(() => deleteAllData(any())).thenAnswer((_) => result.future);
    await readyWith('DELETE');

    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        hasStatus(DeleteAllDataStatus.deleting),
        hasStatus(DeleteAllDataStatus.done),
      ]),
    );
    bloc
      ..add(const DeleteAllRequested())
      ..add(const DeleteAllRequested());
    await pumpEventQueue();
    result.complete(const Right(unit));
    await states;

    verify(() => deleteAllData(any())).called(1);
  });

  test('a server failure shows serverFailed and can be retried', () async {
    when(
      () => deleteAllData(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: '500')));
    await readyWith('DELETE');

    bloc.add(const DeleteAllRequested());
    await pumpEventQueue();

    expect(bloc.state.status, DeleteAllDataStatus.failed);
    expect(bloc.state.errorMessage, t.settings.deleteData.serverFailed);
    expect(bloc.state.confirmation, 'DELETE');

    bloc.add(const DeleteAllRequested());
    await pumpEventQueue();
    verify(() => deleteAllData(any())).called(2);
  });

  test('an auth failure shows the sign-in message', () async {
    when(
      () => deleteAllData(any()),
    ).thenAnswer((_) async => const Left(AuthFailure(message: '401')));
    await readyWith('DELETE');

    bloc.add(const DeleteAllRequested());
    await pumpEventQueue();

    expect(bloc.state.errorMessage, t.common.errors.auth);
  });

  test('a throwing delete ends in failed, never stuck deleting', () async {
    when(() => deleteAllData(any())).thenThrow(StateError('boom'));
    await readyWith('DELETE');

    bloc.add(const DeleteAllRequested());
    await pumpEventQueue();

    expect(bloc.state.status, DeleteAllDataStatus.failed);
    expect(bloc.state.errorMessage, t.common.errors.generic);
  });
}
