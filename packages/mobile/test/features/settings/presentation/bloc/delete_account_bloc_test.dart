import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/delete_account_and_data.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class _MockDeleteAccountAndData extends Mock implements DeleteAccountAndData {}

void main() {
  late _MockDeleteAccountAndData useCase;
  late DeleteAccountBloc bloc;

  setUpAll(() => registerFallbackValue(NoParams()));

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    useCase = _MockDeleteAccountAndData();
    bloc = DeleteAccountBloc(deleteAccountAndData: useCase);
  });

  tearDown(() => bloc.close());

  const deleting = DeleteAccountState(status: DeleteAccountStatus.deleting);

  void failsWith(Failure failure) =>
      when(() => useCase(any())).thenAnswer((_) async => Left(failure));

  test('success emits deleting then deleted', () async {
    when(() => useCase(any())).thenAnswer((_) async => const Right(unit));

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        deleting,
        const DeleteAccountState(status: DeleteAccountStatus.deleted),
      ]),
    );
    bloc.add(const DeleteAccountRequested());
    await expectation;
  });

  test('requires-recent-login failure maps to the localized message', () async {
    failsWith(
      const AuthFailure(
        message: 'no silent account',
        errorCode: FailureCodes.requiresRecentLogin,
      ),
    );

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        deleting,
        DeleteAccountState(
          status: DeleteAccountStatus.failed,
          errorMessage: t.common.errors.requiresRecentLogin,
        ),
      ]),
    );
    bloc.add(const DeleteAccountRequested());
    await expectation;
  });

  test('network failure maps to the offline message', () async {
    failsWith(const NetworkFailure(message: 'offline'));

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        deleting,
        DeleteAccountState(
          status: DeleteAccountStatus.failed,
          errorMessage: t.common.errors.network,
        ),
      ]),
    );
    bloc.add(const DeleteAccountRequested());
    await expectation;
  });

  test('a second request while deleting is dropped', () async {
    final done = Completer<Either<Failure, Unit>>();
    when(() => useCase(any())).thenAnswer((_) => done.future);

    bloc
      ..add(const DeleteAccountRequested())
      ..add(const DeleteAccountRequested());
    await pumpEventQueue();
    done.complete(const Right(unit));
    await pumpEventQueue();

    verify(() => useCase(any())).called(1);
    expect(bloc.state.status, DeleteAccountStatus.deleted);
  });

  test('a throwing use case emits failed with the generic message', () async {
    when(() => useCase(any())).thenThrow(Exception('boom'));

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        deleting,
        DeleteAccountState(
          status: DeleteAccountStatus.failed,
          errorMessage: t.common.errors.generic,
        ),
      ]),
    );
    bloc.add(const DeleteAccountRequested());
    await expectation;
  });
}
