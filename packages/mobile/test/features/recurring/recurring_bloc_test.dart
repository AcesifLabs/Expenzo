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
import 'package:expense_tracker/features/recurring/domain/usecases/process_recurring.dart'
    as uc;
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';

class MockGetRecurringList extends Mock implements GetRecurringList {}

class MockCreateRecurring extends Mock implements create_uc.CreateRecurring {}

class MockUpdateRecurring extends Mock implements uc.UpdateRecurring {}

class MockDeleteRecurring extends Mock implements uc.DeleteRecurring {}

class MockProcessRecurring extends Mock implements uc.ProcessRecurring {}

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
  late MockProcessRecurring mockProcessRecurring;
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
    mockProcessRecurring = MockProcessRecurring();
    bloc = RecurringBloc(
      getRecurringList: mockGetRecurringList,
      createRecurring: mockCreateRecurring,
      updateRecurring: mockUpdateRecurring,
      deleteRecurring: mockDeleteRecurring,
      processRecurring: mockProcessRecurring,
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
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
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
        isA<RecurringLoaded>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateRecurring(testRecurring));
    });

    test('emits [RecurringLoading, RecurringError] on failure', () async {
      when(
        () => mockCreateRecurring(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Create failed')));

      final expected = [
        isA<RecurringLoading>(),
        isA<RecurringError>().having(
          (s) => s.message,
          'message',
          'Create failed',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateRecurring(testRecurring));
    });
  });
}
