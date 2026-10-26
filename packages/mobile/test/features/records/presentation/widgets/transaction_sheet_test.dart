import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/records/data/services/transaction_draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
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
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/pump_localized.dart';
import '../../../../support/receipt_camera.dart';

class _MockRecordBloc extends Mock implements RecordBloc {}

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _MockAddRecord extends Mock implements AddRecord {}

class _MockUpdateRecord extends Mock implements UpdateRecord {}

class _MockDeleteRecord extends Mock implements DeleteRecord {}

class _MockGetBudgets extends Mock implements GetBudgets {}

class _MockGetCategories extends Mock implements GetCategories {}

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
    registerFallbackValue(const GetCategoriesParams());
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

  Future<void> pumpSheet(
    WidgetTester tester, {
    Record? record,
    bool startWithReceiptScan = false,
  }) async {
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
            home: Scaffold(
              body: NewTransactionSheet(
                initialRecord: record,
                startWithReceiptScan: startWithReceiptScan,
              ),
            ),
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

  group('draft', () {
    late TransactionDraftStore drafts;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      drafts = TransactionDraftStore(await SharedPreferences.getInstance());
      di.getIt.registerSingleton<TransactionDraftStore>(drafts);
    });

    tearDown(() => di.getIt.unregister<TransactionDraftStore>());

    testWidgets('typed fields are kept when the app goes to the background', (
      tester,
    ) async {
      await pumpSheet(tester);
      for (final digit in ['4', '5']) {
        await tester.tap(find.text(digit).first);
      }
      await tester.enterText(find.byType(TextField).first, 'Taxi');

      void moveThrough(List<AppLifecycleState> states) {
        for (final state in states) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
      }

      moveThrough(const [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]);
      await tester.pump();

      expect(drafts.load()?.amountText, '45');
      expect(drafts.load()?.note, 'Taxi');
      moveThrough(const [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
    });

    testWidgets('a new sheet opens with the saved draft', (tester) async {
      await drafts.save((
        type: RecordType.expense,
        amountText: '45',
        note: 'Taxi',
        categoryId: null,
        budgetId: null,
        date: DateTime(2026, 10, 24),
      ));

      await pumpSheet(tester);

      expect(find.text('Taxi'), findsOneWidget);
    });

    testWidgets('closing the sheet drops the draft', (tester) async {
      await drafts.save((
        type: RecordType.expense,
        amountText: '45',
        note: 'Taxi',
        categoryId: null,
        budgetId: null,
        date: DateTime(2026, 10, 24),
      ));
      await pumpSheet(tester);

      await tester.pumpWidget(const SizedBox());

      expect(drafts.load(), isNull);
    });
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

  group('number format', () {
    void useFormat({
      int decimalPlaces = 2,
      DigitGrouping grouping = DigitGrouping.comma,
    }) {
      CurrencyFormatter.displayFormat.value = NumberDisplayFormat(
        decimalPlaces: decimalPlaces,
        grouping: grouping,
      );
    }

    tearDown(
      () =>
          CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard,
    );

    Future<Record> saveEdit(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      return verify(() => updateRecord(captureAny())).captured.single as Record;
    }

    testWidgets('dot grouping shows a comma key and saves 1.5', (tester) async {
      useFormat(grouping: DigitGrouping.dot);
      await pumpSheet(tester);
      final symbol = CurrencyFormatter.current.value.symbol;

      expect(find.text('.'), findsNothing);
      for (final key in ['1', ',', '5']) {
        await tester.tap(find.text(key).first);
      }
      await tester.pump();

      expect(find.text('-${symbol}1,5'), findsOneWidget);
    });

    testWidgets('edit prefill parses under dot grouping', (tester) async {
      useFormat(grouping: DigitGrouping.dot);
      await pumpSheet(tester, record: smsRecord);
      final symbol = CurrencyFormatter.current.value.symbol;

      await tester.tap(find.text(','));
      await tester.tap(find.text('5').first);
      await tester.pump();
      expect(find.text('-${symbol}450,5'), findsOneWidget);

      expect((await saveEdit(tester)).amount.abs(), 450.5);
    });

    testWidgets('zero decimal places still saves cents', (tester) async {
      useFormat(decimalPlaces: 0);
      await pumpSheet(tester, record: smsRecord);

      for (final key in ['.', '2', '5']) {
        await tester.tap(find.text(key).first);
      }
      await tester.pump();

      expect((await saveEdit(tester)).amount.abs(), 450.25);
    });
  });

  group('show all budgets', () {
    Future<Object?> pumpSheetWithPicker(
      WidgetTester tester, {
      required String? pickerResult,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      Object? pickerExtra;

      final router = GoRouter(
        initialLocation: '/sheet',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(),
            routes: [
              GoRoute(
                path: 'sheet',
                builder: (_, _) => Scaffold(
                  body: NewTransactionSheet(initialRecord: smsRecord),
                ),
              ),
              GoRoute(
                path: 'budgets/picker',
                builder: (context, state) {
                  pickerExtra = state.extra;

                  return Scaffold(
                    body: TextButton(
                      onPressed: () => context.pop(pickerResult),
                      child: const Text('pick'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RecordBloc>.value(value: recordBloc),
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
          ],
          child: translated(MaterialApp.router(routerConfig: router)),
        ),
      );
      await tester.pump();

      await tester.tap(find.byTooltip(t.records.sheet.showAllBudgets));
      await tester.pumpAndSettle();
      await tester.tap(find.text('pick'));
      await tester.pumpAndSettle();

      return pickerExtra;
    }

    Future<Record> saveEdit(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      return verify(() => updateRecord(captureAny())).captured.single as Record;
    }

    testWidgets('passes the current budget and applies the picked one', (
      tester,
    ) async {
      final extra = await pumpSheetWithPicker(tester, pickerResult: 'budget-2');

      expect(extra, {'selectedId': 'budget-1'});
      expect((await saveEdit(tester)).budgetId, 'budget-2');
    });

    testWidgets('picking No budget clears the link', (tester) async {
      await pumpSheetWithPicker(tester, pickerResult: '');

      expect((await saveEdit(tester)).budgetId, isNull);
    });

    testWidgets('closing the picker keeps the link', (tester) async {
      await pumpSheetWithPicker(tester, pickerResult: null);

      expect((await saveEdit(tester)).budgetId, 'budget-1');
    });
  });

  group('repeat monthly', () {
    late _MockRecurringRepository recurring;

    setUp(() => recurring = _MockRecurringRepository());

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

  group('start with receipt scan', () {
    setUp(() {
      final getCategories = _MockGetCategories();
      when(
        () => getCategories(any()),
      ).thenAnswer((_) async => Right([shopping]));
      di.getIt.registerSingleton<GetCategories>(getCategories);
      mockCameraPermissionDenied();
    });

    tearDown(() async {
      clearCameraPermissionMock();
      await di.getIt.unregister<GetCategories>();
    });

    testWidgets('opens the camera page over the sheet', (tester) async {
      await pumpSheet(tester, startWithReceiptScan: true);
      await pumpPastTransitions(tester);

      expect(find.byType(ReceiptScanCameraPage), findsOneWidget);
      expect(find.text(t.receiptScan.permissionRequired), findsOneWidget);
    });

    testWidgets('does not open the camera without the flag', (tester) async {
      await pumpSheet(tester);
      await pumpPastTransitions(tester);

      expect(find.byType(ReceiptScanCameraPage), findsNothing);
    });

    testWidgets('editing ignores the flag', (tester) async {
      await pumpSheet(tester, record: smsRecord, startWithReceiptScan: true);
      await pumpPastTransitions(tester);

      expect(find.byType(ReceiptScanCameraPage), findsNothing);
    });

    testWidgets('closing the camera leaves an empty add sheet', (tester) async {
      await pumpSheet(tester, startWithReceiptScan: true);
      await pumpPastTransitions(tester);

      await tester.tap(find.text(t.common.close));
      await pumpPastTransitions(tester);

      expect(find.byType(ReceiptScanCameraPage), findsNothing);
      expect(find.byType(NewTransactionSheet), findsOneWidget);
      expect(find.text('Add expense'), findsOneWidget);
    });

    testWidgets('waits for the sheet to finish opening', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      di.getIt.registerSingleton<RecurringRepository>(
        _MockRecurringRepository(),
      );
      addTearDown(() => di.getIt.unregister<RecurringRepository>());
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<RecordBloc>.value(value: recordBloc),
            BlocProvider<CategoryBloc>.value(value: categoryBloc),
          ],
          child: translated(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => unawaited(
                      showTransactionSheet(context, startWithReceiptScan: true),
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(NewTransactionSheet), findsOneWidget);
      expect(find.byType(ReceiptScanCameraPage), findsNothing);

      await pumpPastTransitions(tester);

      expect(find.byType(ReceiptScanCameraPage), findsOneWidget);
    });
  });
}
