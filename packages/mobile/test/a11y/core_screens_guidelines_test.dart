import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart'
    hide CategoryAmount;
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/reports/domain/entities/category_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/date_amount.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/entities/spending_insights.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_insights.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_state.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_screen.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';

import '../support/factories/budget_factory.dart';
import '../support/factories/record_factory.dart';
import '../support/pump_localized.dart';

class _MockRecordBloc extends Mock implements RecordBloc {}

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _MockBudgetBloc extends Mock implements BudgetBloc {}

class _MockReportsBloc extends Mock implements ReportsBloc {}

class _MockDashboardBloc extends Mock implements DashboardBloc {}

class _MockAuthBloc extends Mock implements AuthBloc {}

class _MockGetBudgets extends Mock implements GetBudgets {}

class _MockSettingsBloc extends Mock implements SettingsBloc {}

/// Points a mocked bloc at one fixed state.
void _stub<S>(BlocBase<S> bloc, S state) {
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => Stream<S>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  // Unstubbed `add` calls are no-ops on a mocktail mock.
}

/// A mocked bloc stuck in [state].
B _mock<B extends BlocBase<S>, S>(B bloc, S state) {
  _stub<S>(bloc, state);

  return bloc;
}

/// Runs the tap-target and label guidelines (docs: DESIGN.md, Accessibility)
/// on a phone-sized screen.
Future<void> _expectGuidelines(WidgetTester tester, Widget screen) async {
  final handle = tester.ensureSemantics();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    translated(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));

  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  handle.dispose();
}

void main() {
  final records = [
    makeRecord(id: 'r1', amount: -122, description: 'Lunch'),
    makeRecord(
      id: 'r2',
      amount: 5000,
      description: 'Salary',
      recordType: RecordType.income,
    ),
  ];

  setUp(() {
    // Skip the real feature start-up (database, network) in widget tests.
    di.getIt.registerSingleton<Future<void>>(
      Future<void>.value(),
      instanceName: 'featureReady',
    );
  });

  tearDown(() => di.getIt.reset());

  testWidgets('Home', (tester) async {
    // The auto-import setup card reads the app-wide settings.
    di.getIt.registerSingleton<SettingsBloc>(
      _mock<_MockSettingsBloc, SettingsState>(
        _MockSettingsBloc(),
        const SettingsInitial(),
      ),
    );
    await _expectGuidelines(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(
            value: _mock<_MockAuthBloc, AuthState>(
              _MockAuthBloc(),
              const Unauthenticated(),
            ),
          ),
          BlocProvider<DashboardBloc>.value(
            value: _mock<_MockDashboardBloc, DashboardState>(
              _MockDashboardBloc(),
              DashboardLoaded(
                summary: DashboardSummary(
                  totalIncome: 5000,
                  totalExpense: 122,
                  totalSpent: 122,
                  previousPeriodTotal: 0,
                  categoryBreakdown: const [],
                  recentTransactions: records,
                ),
                dateRange: DateRange.thisMonth(),
              ),
            ),
          ),
        ],
        child: const DashboardView(),
      ),
    );
  });

  testWidgets('Activity', (tester) async {
    await _expectGuidelines(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<RecordBloc>.value(
            value: _mock<_MockRecordBloc, RecordState>(
              _MockRecordBloc(),
              RecordLoaded(records: records),
            ),
          ),
          BlocProvider<CategoryBloc>.value(
            value: _mock<_MockCategoryBloc, CategoryState>(
              _MockCategoryBloc(),
              const CategoryLoaded([]),
            ),
          ),
        ],
        child: const RecordListView(),
      ),
    );
  });

  testWidgets('Budgets', (tester) async {
    final budget = makeBudget(id: 'b1', name: 'Food', amount: 1000);
    final now = DateTime.now();
    final progress = BudgetProgress(
      budgetId: 'b1',
      budgetAmount: 1000,
      effectiveAmount: 1000,
      spentAmount: 850,
      rolloverAmount: 0,
      percentage: 85,
      isOverBudget: false,
      name: 'Food',
      periodRange: DateTimeRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1),
      ),
      period: BudgetPeriod.monthly,
    );

    await _expectGuidelines(
      tester,
      BlocProvider<BudgetBloc>.value(
        value: _mock<_MockBudgetBloc, BudgetState>(
          _MockBudgetBloc(),
          BudgetLoaded([budget], progressByBudgetId: {'b1': progress}),
        ),
        child: const BudgetListView(),
      ),
    );
  });

  testWidgets('Reports', (tester) async {
    final now = DateTime.now();
    final reports = _mock<_MockReportsBloc, ReportsState>(
      _MockReportsBloc(),
      ReportsLoaded(
        spendingTrend: [DateAmount(date: now, amount: 122)],
        categoryBreakdown: const [
          CategoryAmount(
            categoryId: 'c1',
            categoryName: 'Food',
            emoji: 'forkKnife',
            amount: 122,
            percentage: 100,
            colorHex: '#F8BBD0',
          ),
        ],
        insights: const SpendingInsights(
          highestDayAmount: 122,
          avgDailySpending: 4,
          totalTransactionCount: 1,
          totalSpent: 122,
        ),
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
        granularity: Granularity.daily,
      ),
    );
    di.getIt
      ..registerFactory<ReportsBloc>(() => reports)
      ..registerSingleton<GetInsights>(const GetInsights());

    await _expectGuidelines(tester, const ReportsScreen(isTab: true));
  });

  testWidgets('Transaction sheet', (tester) async {
    final getBudgets = _MockGetBudgets();
    when(() => getBudgets()).thenAnswer((_) async => const Right([]));
    di.getIt.registerSingleton<GetBudgets>(getBudgets);

    await _expectGuidelines(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<RecordBloc>.value(
            value: _mock<_MockRecordBloc, RecordState>(
              _MockRecordBloc(),
              const RecordInitial(),
            ),
          ),
          BlocProvider<CategoryBloc>.value(
            value: _mock<_MockCategoryBloc, CategoryState>(
              _MockCategoryBloc(),
              const CategoryLoaded([]),
            ),
          ),
        ],
        child: const NewTransactionSheet(),
      ),
    );
  });
}
