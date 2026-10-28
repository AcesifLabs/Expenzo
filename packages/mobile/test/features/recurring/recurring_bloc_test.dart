import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/get_recurring_list.dart';
import 'package:expense_tracker/features/recurring/domain/usecases/create_recurring.dart'
    as create_uc;
import 'package:expense_tracker/features/recurring/domain/usecases/update_recurring.dart'
    as uc;
import 'package:expense_tracker/features/recurring/domain/usecases/delete_recurring.dart'
    as uc;
import 'package:expense_tracker/features/recurring/domain/usecases/post_due_recurring.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class MockGetRecurringList extends Mock implements GetRecurringList {}

class MockCreateRecurring extends Mock implements create_uc.CreateRecurring {}

class MockUpdateRecurring extends Mock implements uc.UpdateRecurring {}

class MockDeleteRecurring extends Mock implements uc.DeleteRecurring {}

class MockPostDueRecurring extends Mock implements PostDueRecurring {}

class _NoParamsFake extends Fake implements NoParams {}

class _RecurringTransactionFake extends Fake implements RecurringTransaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(_NoParamsFake());
    registerFallbackValue(_RecurringTransactionFake());
  });
  late MockGetRecurringList mockGetRecurringList;
  late MockCreateRecurring mockCreateRecurring;
  late MockUpdateRecurring mockUpdateRecurring;
  late MockDeleteRecurring mockDeleteRecurring;
  late MockPostDueRecurring mockPostDueRecurring;
  late RecurringBloc bloc;

  final testRecurring = RecurringTransaction(
    id: 'rec-1',
    description: 'Rent',
    amount: 1500,
    categoryId: 'cat-1',
    frequency: RecurringFrequency.monthly,
    startDate: DateTime.now(),
    nextOccurrence: DateTime.now(),
    dayOfMonth: 1,
    isActive: true,
  );

  setUp(() {
    mockGetRecurringList = MockGetRecurringList();
    mockCreateRecurring = MockCreateRecurring();
    mockUpdateRecurring = MockUpdateRecurring();
    mockDeleteRecurring = MockDeleteRecurring();
    mockPostDueRecurring = MockPostDueRecurring();
    bloc = RecurringBloc(
      getRecurringList: mockGetRecurringList,
      createRecurring: mockCreateRecurring,
      updateRecurring: mockUpdateRecurring,
      deleteRecurring: mockDeleteRecurring,
      postDueRecurring: mockPostDueRecurring,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadRecurring', () {
    test('emits [RecurringLoading, RecurringLoaded] on success', () async {
      when(
        () => mockGetRecurringList(any()),
      ).thenAnswer((_) async => Right([testRecurring]));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringLoaded>().having(
          (s) => s.recurringList.length,
          'recurringList length',
          1,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadRecurring());
    });

    test('emits [RecurringLoading, RecurringError] on failure', () async {
      when(
        () => mockGetRecurringList(any()),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'Failed to load')));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          t.common.errors.storage,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(LoadRecurring());
    });
  });

  group('CreateRecurring', () {
    test('emits loading, success, then reloads on success', () async {
      when(
        () => mockCreateRecurring(any()),
      ).thenAnswer((_) async => Right(testRecurring));
      when(
        () => mockGetRecurringList(any()),
      ).thenAnswer((_) async => Right([testRecurring]));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringOperationSuccess>(),
        isA<RecurringLoading>(),
        isA<RecurringLoaded>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateRecurring(testRecurring));
    });

    test('emits [RecurringLoading, RecurringError] on failure', () async {
      when(
        () => mockCreateRecurring(any()),
      ).thenAnswer((_) async => Left(CacheFailure(message: 'Create failed')));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          t.common.errors.storage,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateRecurring(testRecurring));
    });
  });

  group('ProcessRecurring', () {
    void posts(int created) {
      when(
        () => mockPostDueRecurring(automatic: any(named: 'automatic')),
      ).thenAnswer((_) async => Right(created));
      when(
        () => mockGetRecurringList(any()),
      ).thenAnswer((_) async => Right([testRecurring]));
    }

    test('posted items emit RecurringProcessed, then reload', () async {
      posts(2);

      final expected = [
        isA<RecurringLoading>(),
        const RecurringProcessed(2),
        isA<RecurringLoading>(),
        isA<RecurringLoaded>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const ProcessRecurring());
    });

    test('nothing due emits RecurringProcessed(0)', () async {
      posts(0);

      expectLater(
        bloc.stream,
        emitsInOrder([isA<RecurringLoading>(), const RecurringProcessed(0)]),
      );
      bloc.add(const ProcessRecurring());
    });

    test('an automatic run is marked automatic and posts only included '
        'items', () async {
      posts(0);

      final emitted = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          const RecurringProcessed(0, automatic: true),
        ]),
      );
      bloc.add(const ProcessRecurring(automatic: true));
      await emitted;
      verify(() => mockPostDueRecurring(automatic: true)).called(1);
    });

    test('a failure emits RecurringError, then reloads', () async {
      when(
        () => mockPostDueRecurring(automatic: any(named: 'automatic')),
      ).thenAnswer((_) async => const Left(CacheFailure(message: 'db')));
      when(
        () => mockGetRecurringList(any()),
      ).thenAnswer((_) async => const Right([]));

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          isA<RecurringError>(),
          isA<RecurringLoading>(),
          isA<RecurringLoaded>(),
        ]),
      );
      bloc.add(const ProcessRecurring());
    });
  });

  test('a double tap on Add creates one recurring item', () async {
    when(() => mockCreateRecurring(any())).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));

      return Right(testRecurring);
    });
    when(
      () => mockGetRecurringList(any()),
    ).thenAnswer((_) async => Right([testRecurring]));

    bloc
      ..add(CreateRecurring(testRecurring))
      ..add(CreateRecurring(testRecurring));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    verify(() => mockCreateRecurring(any())).called(1);
  });
}
