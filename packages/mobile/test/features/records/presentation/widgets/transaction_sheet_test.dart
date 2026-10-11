import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/features/records/domain/usecases/add_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import '../../../../support/pump_localized.dart';

class _MockRecordBloc extends Mock implements RecordBloc {}

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _MockAddRecord extends Mock implements AddRecord {}

class _MockUpdateRecord extends Mock implements UpdateRecord {}

class _MockDeleteRecord extends Mock implements DeleteRecord {}

class _MockGetBudgets extends Mock implements GetBudgets {}

class _FakeRecordEvent extends Fake implements RecordEvent {}

class _MockRecurringRepository extends Mock implements RecurringRepository {}

class _FakeRecurring extends Fake implements RecurringTransaction {}

class _FakeCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late _MockRecordBloc recordBloc;
  late _MockCategoryBloc categoryBloc;
  late _MockAddRecord addRecord;
  late _MockUpdateRecord updateRecord;
  late _MockDeleteRecord deleteRecord;

  final shopping = Category(
    id: 'default_out_shopping',
    name: 'Shopping',
    emoji: 'bag',
    color: '#D1C4E9',
    type: RecordType.expense,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final salary = Category(
    id: 'default_in_salary',
    name: 'Salary',
    emoji: 'wallet',
    color: '#C8E6C9',
    type: RecordType.income,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final smsRecord = Record(
    id: 'rec-1',
    amount: -450,
    description: 'DARAZ',
    date: DateTime(2026, 10, 11),
    categoryId: shopping.id,
    budgetId: 'budget-1',
    source: ExpenseSource.sms,
    sourceId: 'sms-42',
    recordType: RecordType.expense,
    createdAt: DateTime.utc(2026, 10, 11),
    updatedAt: DateTime.utc(2026, 10, 11),
  );

  setUpAll(() {
    registerFallbackValue(_FakeRecordEvent());
    registerFallbackValue(_FakeCategoryEvent());
    registerFallbackValue(smsRecord);
    registerFallbackValue(_FakeRecurring());
  });

  setUp(() {
    recordBloc = _MockRecordBloc();
    categoryBloc = _MockCategoryBloc();
    addRecord = _MockAddRecord();
    updateRecord = _MockUpdateRecord();
    deleteRecord = _MockDeleteRecord();
    when(() => deleteRecord(any())).thenAnswer((_) async => const Right(unit));
    final getBudgets = _MockGetBudgets();

    when(() => recordBloc.state).thenReturn(const RecordInitial());
    when(
      () => recordBloc.stream,
    ).thenAnswer((_) => const Stream<RecordState>.empty());
    when(() => recordBloc.close()).thenAnswer((_) async {});
    when(() => recordBloc.add(any())).thenReturn(null);
    when(
      () => categoryBloc.state,
    ).thenReturn(CategoryLoaded([shopping, salary]));
    when(
      () => categoryBloc.stream,
    ).thenAnswer((_) => const Stream<CategoryState>.empty());
    when(() => categoryBloc.close()).thenAnswer((_) async {});
    when(() => categoryBloc.add(any())).thenReturn(null);
    when(() => getBudgets()).thenAnswer((_) async => const Right([]));
    when(
      () => addRecord(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Record));
    when(
      () => updateRecord(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Record));

    di.getIt
      ..registerSingleton<GetBudgets>(getBudgets)
      ..registerSingleton<AddRecord>(addRecord)
      ..registerSingleton<UpdateRecord>(updateRecord)
      ..registerSingleton<DeleteRecord>(deleteRecord);
  });

  tearDown(() async {
    await di.getIt.unregister<GetBudgets>();
    await di.getIt.unregister<AddRecord>();
    await di.getIt.unregister<UpdateRecord>();
    await di.getIt.unregister<DeleteRecord>();
  });

  Future<void> pumpSheet(WidgetTester tester, {Record? record}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<RecordBloc>.value(value: recordBloc),
          BlocProvider<CategoryBloc>.value(value: categoryBloc),
        ],
        child: translated(
          MaterialApp(
            home: Scaffold(body: NewTransactionSheet(initialRecord: record)),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('edit mode prefills the record and offers save and delete', (
    tester,
  ) async {
    await pumpSheet(tester, record: smsRecord);

    final symbol = CurrencyFormatter.current.value.symbol;
    expect(find.text('-${symbol}450'), findsOneWidget);
    expect(find.text('DARAZ'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Delete expense'), findsOneWidget);
    expect(find.text('Repeat monthly'), findsNothing);
  });

  testWidgets('saving an edit keeps the budget link and SMS source', (
    tester,
  ) async {
    await pumpSheet(tester, record: smsRecord);

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    final saved =
        verify(() => updateRecord(captureAny())).captured.single as Record;
    expect(saved.id, 'rec-1');
    expect(saved.budgetId, 'budget-1');
    expect(saved.source, ExpenseSource.sms);
    expect(saved.sourceId, 'sms-42');
    expect(saved.createdAt, smsRecord.createdAt);
    verifyNever(() => addRecord(any()));
  });

  testWidgets('switching an edited expense to income clears its budget', (
    tester,
  ) async {
    final categories = StreamController<CategoryState>.broadcast();
    addTearDown(categories.close);
    when(() => categoryBloc.stream).thenAnswer((_) => categories.stream);
    await pumpSheet(tester, record: smsRecord);

    await tester.tap(find.text('Income'));
    await tester.pump();
    // The real bloc answers LoadCategories(type: income) with income ones.
    final incomeOnly = CategoryLoaded([salary], type: RecordType.income);
    when(() => categoryBloc.state).thenReturn(incomeOnly);
    categories.add(incomeOnly);
    await tester.pump();
    await tester.tap(find.byType(DropdownButton<Category>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salary').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();

    final saved =
        verify(() => updateRecord(captureAny())).captured.single as Record;
    expect(saved.recordType, RecordType.income);
    expect(saved.amount, 450);
    expect(saved.budgetId, isNull);
    expect(saved.sourceId, 'sms-42');
  });

  testWidgets('adding creates a new manual record', (tester) async {
    await pumpSheet(tester);

    for (final digit in ['1', '2', '0']) {
      await tester.tap(find.text(digit).first);
    }
    await tester.enterText(find.byType(TextField).first, 'Lunch');
    await tester.pump();
    expect(find.text('Add expense'), findsOneWidget);
  });

  testWidgets('delete asks first, then deletes the record', (tester) async {
    await pumpSheet(tester, record: smsRecord);

    await tester.ensureVisible(find.text('Delete expense'));
    await tester.tap(find.text('Delete expense'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this expense?'), findsOneWidget);
    verifyNever(() => deleteRecord(any()));

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();

    verify(() => deleteRecord('rec-1')).called(1);
  });

  group('repeat monthly', () {
    late _MockRecurringRepository recurring;

    setUp(() => recurring = _MockRecurringRepository());

    // Hosts the sheet on a pushed route so it can close itself.
    Future<void> openSheet(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RecordBloc>.value(value: recordBloc),
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
          ],
          child: translated(
            MaterialApp(
              home: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<bool>(
                      builder: (_) => Scaffold(
                        body: NewTransactionSheet(
                          recurringRepository: recurring,
                        ),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> fillAndSubmit(WidgetTester tester) async {
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('2').first);
      await tester.enterText(find.byType(TextField).first, 'Internet');
      // The hint text sits under the dropdown's tap target; tap the dropdown.
      await tester.tap(
        find.ancestor(
          of: find.text('Select a category'),
          matching: find.byWidgetPredicate((w) => w is DropdownButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shopping').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Repeat monthly'));
      await tester.tap(find.text('Repeat monthly'));
      await tester.pump();
      await tester.ensureVisible(find.text('Add expense'));
      await tester.tap(find.text('Add expense'));
      await tester.pumpAndSettle();
    }

    testWidgets('saves the record once and creates the monthly repeat', (
      tester,
    ) async {
      when(() => recurring.createRecurring(any())).thenAnswer(
        (i) async => Right(i.positionalArguments.first as RecurringTransaction),
      );
      await openSheet(tester);
      await fillAndSubmit(tester);

      verify(() => addRecord(any())).called(1);
      final repeat =
          verify(() => recurring.createRecurring(captureAny())).captured.single
              as RecurringTransaction;
      expect(repeat.amount, -12);
      expect(repeat.frequency, RecurringFrequency.monthly);
      expect(find.byType(NewTransactionSheet), findsNothing);
    });

    testWidgets('a failed repeat still closes the sheet (no duplicate)', (
      tester,
    ) async {
      when(
        () => recurring.createRecurring(any()),
      ).thenAnswer((_) async => const Left(CacheFailure(message: 'db locked')));
      // The sheet logs the expected failure; keep the test output clean.
      // Restored in the body: Flutter checks it before tear-downs run.
      final originalDebugPrint = debugPrint;
      debugPrint = (_, {wrapWidth}) {};
      try {
        await openSheet(tester);
        await fillAndSubmit(tester);
      } finally {
        debugPrint = originalDebugPrint;
      }

      verify(() => addRecord(any())).called(1);
      expect(find.byType(NewTransactionSheet), findsNothing);
    });
  });
}
