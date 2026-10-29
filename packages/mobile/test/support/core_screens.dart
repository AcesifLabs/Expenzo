import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/app_font_size.dart';
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
import 'package:expense_tracker/features/budgets/domain/entities/budget_plan_snapshot.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_plan_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_plan_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart'
    hide CategoryAmount;
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
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
import 'package:expense_tracker/features/settings/presentation/widgets/calendar_month_preview.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_text_scale.dart';

import 'connectivity_test_support.dart';
import 'factories/budget_factory.dart';
import 'factories/record_factory.dart';
import 'pump_localized.dart';

class MockRecordBloc extends Mock implements RecordBloc {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

class MockBudgetBloc extends Mock implements BudgetBloc {}

class MockBudgetPlanBloc extends Mock implements BudgetPlanBloc {}

class MockReportsBloc extends Mock implements ReportsBloc {}

class MockDashboardBloc extends Mock implements DashboardBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockGetBudgets extends Mock implements GetBudgets {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

enum TestPhone {
  large(Size(1080, 2400), 2.625),

  small(Size(720, 1280), 2.0),

  tablet(Size(1600, 2560), 2.0);

  final Size physicalSize;
  final double devicePixelRatio;

  const TestPhone(this.physicalSize, this.devicePixelRatio);
}

void stubBloc<S>(BlocBase<S> bloc, S state) {
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => Stream<S>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
}

B mockBloc<B extends BlocBase<S>, S>(B bloc, S state) {
  stubBloc<S>(bloc, state);

  return bloc;
}

class MockGoalBloc extends Mock implements GoalBloc {}

class MockRecurringRepository extends Mock implements RecurringRepository {}

const _permissionChannel = MethodChannel(
  'flutter.baseflow.com/permissions/methods',
);

void registerScreenTestDependencies() {
  di.getIt.registerSingleton<Future<void>>(
    Future<void>.value(),
    instanceName: 'featureReady',
  );
  registerTestConnectivity();
  registerNoGoalBloc();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(
    _permissionChannel,
    (call) async => call.method == 'checkPermissionStatus' ? 0 : null,
  );
  addTearDown(
    () => messenger.setMockMethodCallHandler(_permissionChannel, null),
  );
}

void registerNoGoalBloc() {
  di.getIt.registerFactory<GoalBloc>(
    () => mockBloc<MockGoalBloc, GoalState>(
      MockGoalBloc(),
      const GoalState(status: GoalStatus.ready),
    ),
  );
}

List<Record> get sampleRecords => [
  makeRecord(id: 'r1', amount: -122, description: 'Lunch'),
  makeRecord(
    id: 'r2',
    amount: 5000,
    description: 'Salary',
    recordType: RecordType.income,
  ),
];

DashboardBloc _loadedDashboardBloc([DashboardState? state]) {
  return mockBloc<MockDashboardBloc, DashboardState>(
    MockDashboardBloc(),
    state ??
        DashboardLoaded(
          summary: DashboardSummary(
            totalIncome: 5000,
            totalExpense: 122,
            totalSpent: 122,
            previousPeriodTotal: 0,
            categoryBreakdown: const [],
            recentTransactions: sampleRecords,
          ),
          dateRange: DateRange.thisMonth(),
        ),
  );
}

const emptyDashboardSummary = DashboardSummary(
  totalIncome: 0,
  totalExpense: 0,
  totalSpent: 0,
  previousPeriodTotal: 0,
  categoryBreakdown: [],
  recentTransactions: [],
);

AuthBloc _signedOutAuthBloc() {
  return mockBloc<MockAuthBloc, AuthState>(
    MockAuthBloc(),
    const Unauthenticated(),
  );
}

void _registerHomeSettings() {
  di.getIt.registerSingleton<SettingsBloc>(
    mockBloc<MockSettingsBloc, SettingsState>(
      MockSettingsBloc(),
      const SettingsInitial(),
    ),
  );
}

Widget homeScreen({DashboardState? state}) {
  _registerHomeSettings();

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: _signedOutAuthBloc()),
      BlocProvider<DashboardBloc>.value(value: _loadedDashboardBloc(state)),
    ],
    child: const DashboardView(),
  );
}

Widget appShellScreen() {
  _registerHomeSettings();
  final dashboard = _loadedDashboardBloc();
  di.getIt.registerFactory<DashboardBloc>(() => dashboard);
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (_, _) => const AppShell())],
  );
  addTearDown(router.dispose);

  return BlocProvider<AuthBloc>.value(
    value: _signedOutAuthBloc(),
    child: Router.withConfig(config: router),
  );
}

Widget activityScreen({RecordState? state}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<RecordBloc>.value(
        value: mockBloc<MockRecordBloc, RecordState>(
          MockRecordBloc(),
          state ?? RecordLoaded(records: sampleRecords),
        ),
      ),
      BlocProvider<CategoryBloc>.value(
        value: mockBloc<MockCategoryBloc, CategoryState>(
          MockCategoryBloc(),
          const CategoryLoaded([]),
        ),
      ),
    ],
    child: const RecordListView(),
  );
}

BudgetProgress sampleBudgetProgress() {
  final now = clock.now();

  return BudgetProgress(
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
}

Widget budgetsScreen({BudgetState? state}) {
  final budget = makeBudget(id: 'b1', name: 'Food', amount: 1000);

  return BlocProvider<BudgetBloc>.value(
    value: mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      state ??
          BudgetLoaded(
            [budget],
            progressByBudgetId: {'b1': sampleBudgetProgress()},
          ),
    ),
    child: const BudgetListView(),
  );
}

Widget budgetPlanScreen({BudgetPlanState? state}) {
  final food = makeBudget(id: 'b1', name: 'Food', amount: 1000);
  final rent = makeBudget(id: 'b2', name: 'Rent', amount: 2500);
  final bloc = mockBloc<MockBudgetPlanBloc, BudgetPlanState>(
    MockBudgetPlanBloc(),
    state ??
        BudgetPlanEditing(
          stored: BudgetPlanSnapshot(
            monthlyIncome: 5000,
            recurringTotal: 500,
            budgets: [food, rent],
          ),
          income: 5000,
          rows: const [
            PlanRow(key: 'b1', budgetId: 'b1', name: 'Food', amount: 1000),
            PlanRow(key: 'b2', budgetId: 'b2', name: 'Rent', amount: 2500),
          ],
        ),
  );
  when(() => bloc.add(const BudgetPlanLoadRequested())).thenReturn(null);

  return BlocProvider<BudgetPlanBloc>.value(
    value: bloc,
    child: const BudgetPlanPage(),
  );
}

Widget budgetDetailsScreen() {
  final budget = makeBudget(id: 'b1', name: 'Food', amount: 1000);
  final progress = sampleBudgetProgress();

  return BlocProvider<BudgetBloc>.value(
    value: mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      BudgetLoaded(
        [budget],
        progressByBudgetId: {'b1': progress},
        selectedBudgetId: 'b1',
        selectedBudgetTransactions: sampleRecords,
      ),
    ),
    child: BudgetDetailsPage(progress: progress),
  );
}

Widget budgetFormScreen() {
  final budget = makeBudget(id: 'b1', name: 'Food', amount: 1000);

  return BlocProvider<BudgetBloc>.value(
    value: mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      BudgetLoaded([budget]),
    ),
    child: BudgetFormPage(budget: budget),
  );
}

Widget reportsScreen({ReportsState? state}) {
  final now = clock.now();
  final reports = mockBloc<MockReportsBloc, ReportsState>(
    MockReportsBloc(),
    state ??
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

  return const ReportsScreen(isTab: true);
}

Widget transactionSheetScreen() {
  final getBudgets = MockGetBudgets();
  when(() => getBudgets()).thenAnswer((_) async => const Right([]));
  di.getIt.registerSingleton<GetBudgets>(getBudgets);

  return MultiBlocProvider(
    providers: [
      BlocProvider<RecordBloc>.value(
        value: mockBloc<MockRecordBloc, RecordState>(
          MockRecordBloc(),
          const RecordInitial(),
        ),
      ),
      BlocProvider<CategoryBloc>.value(
        value: mockBloc<MockCategoryBloc, CategoryState>(
          MockCategoryBloc(),
          const CategoryLoaded([]),
        ),
      ),
    ],
    child: NewTransactionSheet(recurringRepository: MockRecurringRepository()),
  );
}

void useTestPhone(WidgetTester tester, TestPhone phone) {
  tester.view.physicalSize = phone.physicalSize;
  tester.view.devicePixelRatio = phone.devicePixelRatio;
  addTearDown(tester.view.reset);
}

Future<void> pumpAtMaxScale(
  WidgetTester tester,
  Widget screen, {
  TestPhone phone = TestPhone.large,
  AppLocale locale = AppLocale.en,
  ThemeData? theme,
  Widget Function(Widget app)? wrap,
}) async {
  useTestPhone(tester, phone);
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await pumpLocalized(
    tester,
    AppTextScale(
      factor: AppFontSize.extraLarge.scale,
      child: Scaffold(body: screen),
    ),
    locale: locale,
    theme: theme ?? AppTheme.lightTheme,
    wrap: wrap,
  );
  await tester.pump(const Duration(milliseconds: 500));

  expectLayoutFits(tester);
}

void expectLayoutFits(WidgetTester tester) {
  final error = tester.takeException();

  expect(
    error,
    isNull,
    reason: error is FlutterError ? error.toStringDeep() : null,
  );
  expectNoClippedText(tester);
}

List<String> clippedTexts(WidgetTester tester) {
  final clipped = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || !paragraph.hasSize) continue;

    if (element.findAncestorWidgetOfExactType<CalendarMonthPreview>() != null) {
      continue;
    }
    final needed = paragraph.getMinIntrinsicHeight(paragraph.size.width);
    if (needed > paragraph.size.height + 0.5) {
      clipped.add(
        '"${paragraph.text.toPlainText()}" needs '
        '${needed.toStringAsFixed(1)} px, got '
        '${paragraph.size.height.toStringAsFixed(1)} px',
      );
    }
  }

  return clipped;
}

void expectNoClippedText(WidgetTester tester) {
  expect(clippedTexts(tester), isEmpty, reason: 'Text is clipped');
}

Future<void> expectReachable(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}
