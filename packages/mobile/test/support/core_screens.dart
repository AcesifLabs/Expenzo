import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_text_scale.dart';

import 'factories/budget_factory.dart';
import 'factories/record_factory.dart';
import 'pump_localized.dart';

/// Whole screens with mocked blocs, shared by the accessibility guideline
/// test and the large-text overflow test.
///
/// Call [registerScreenTestDependencies] in `setUp` and `di.getIt.reset()`
/// in `tearDown`; each builder registers the extra GetIt entries its screen
/// needs, so call it inside the test body.

class MockRecordBloc extends Mock implements RecordBloc {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

class MockBudgetBloc extends Mock implements BudgetBloc {}

class MockReportsBloc extends Mock implements ReportsBloc {}

class MockDashboardBloc extends Mock implements DashboardBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockGetBudgets extends Mock implements GetBudgets {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

/// Phone sizes the screen tests run at.
enum TestPhone {
  /// About 411×914 logical pixels.
  large(Size(1080, 2400), 2.625),

  /// About 360×640 logical pixels, the harder case.
  small(Size(720, 1280), 2.0);

  final Size physicalSize;
  final double devicePixelRatio;

  const TestPhone(this.physicalSize, this.devicePixelRatio);
}

/// Points a mocked bloc at one fixed state.
void stubBloc<S>(BlocBase<S> bloc, S state) {
  when(() => bloc.state).thenReturn(state);
  when(() => bloc.stream).thenAnswer((_) => Stream<S>.empty());
  when(() => bloc.close()).thenAnswer((_) async {});
  // Unstubbed `add` calls are no-ops on a mocktail mock.
}

/// A mocked bloc stuck in [state].
B mockBloc<B extends BlocBase<S>, S>(B bloc, S state) {
  stubBloc<S>(bloc, state);

  return bloc;
}

/// Skips the real feature start-up (database, network) in widget tests.
void registerScreenTestDependencies() {
  di.getIt.registerSingleton<Future<void>>(
    Future<void>.value(),
    instanceName: 'featureReady',
  );
}

/// One expense and one income, as Home and Activity show them.
List<Record> get sampleRecords => [
  makeRecord(id: 'r1', amount: -122, description: 'Lunch'),
  makeRecord(
    id: 'r2',
    amount: 5000,
    description: 'Salary',
    recordType: RecordType.income,
  ),
];

/// Home's dashboard with this month's income, spending and two records.
DashboardBloc _loadedDashboardBloc() {
  return mockBloc<MockDashboardBloc, DashboardState>(
    MockDashboardBloc(),
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

AuthBloc _signedOutAuthBloc() {
  return mockBloc<MockAuthBloc, AuthState>(
    MockAuthBloc(),
    const Unauthenticated(),
  );
}

/// The auto-import setup card on Home reads the app-wide settings.
void _registerHomeSettings() {
  di.getIt.registerSingleton<SettingsBloc>(
    mockBloc<MockSettingsBloc, SettingsState>(
      MockSettingsBloc(),
      const SettingsInitial(),
    ),
  );
}

Widget homeScreen() {
  _registerHomeSettings();

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: _signedOutAuthBloc()),
      BlocProvider<DashboardBloc>.value(value: _loadedDashboardBloc()),
    ],
    child: const DashboardView(),
  );
}

/// The app shell on its Home tab, with the bottom navigation bar. Only the
/// selected tab is built, so Home's blocs are all it needs.
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

Widget activityScreen() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<RecordBloc>.value(
        value: mockBloc<MockRecordBloc, RecordState>(
          MockRecordBloc(),
          RecordLoaded(records: sampleRecords),
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

/// One Food budget, 85% spent this month.
BudgetProgress sampleBudgetProgress() {
  final now = DateTime.now();

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

Widget budgetsScreen() {
  final budget = makeBudget(id: 'b1', name: 'Food', amount: 1000);

  return BlocProvider<BudgetBloc>.value(
    value: mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      BudgetLoaded(
        [budget],
        progressByBudgetId: {'b1': sampleBudgetProgress()},
      ),
    ),
    child: const BudgetListView(),
  );
}

/// The Food budget's details, with its two transactions loaded.
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

/// Editing the Food budget, so every field is filled.
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

Widget reportsScreen() {
  final now = DateTime.now();
  final reports = mockBloc<MockReportsBloc, ReportsState>(
    MockReportsBloc(),
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
    child: const NewTransactionSheet(),
  );
}

/// Sizes the test view to [phone]; reset when the test ends.
void useTestPhone(WidgetTester tester, TestPhone phone) {
  tester.view.physicalSize = phone.physicalSize;
  tester.view.devicePixelRatio = phone.devicePixelRatio;
  addTearDown(tester.view.reset);
}

/// Pumps [screen] at the largest text the app allows and fails on any
/// overflow or clipped text.
///
/// The device scale is 2.0 and Font size is Extra large, so the real
/// [AppTextScale] clamp brings text to exactly `AppConstants.maxTextScale`.
/// [wrap] puts providers above the app, as settings page tests need.
Future<void> pumpAtMaxScale(
  WidgetTester tester,
  Widget screen, {
  TestPhone phone = TestPhone.large,
  AppLocale locale = AppLocale.en,
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
    theme: AppTheme.lightTheme,
    wrap: wrap,
  );
  await tester.pump(const Duration(milliseconds: 500));

  expectLayoutFits(tester);
}

/// No overflow was reported and no text on screen is clipped.
void expectLayoutFits(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  expectNoClippedText(tester);
}

/// Texts on screen laid out shorter than they need: a fixed-height box cut
/// them off. Deliberate `maxLines` + ellipsis is not clipping, since the
/// intrinsic height respects `maxLines`.
List<String> clippedTexts(WidgetTester tester) {
  final clipped = <String>[];
  for (final element in find.byType(RichText).evaluate()) {
    final paragraph = element.renderObject;
    if (paragraph is! RenderParagraph || !paragraph.hasSize) continue;
    // Flutter fixes the calendar's day cells, and the test font's square
    // glyphs make two-digit days look twice as wide as a real font does.
    // The preview clamps its own text; it is checked on a device.
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

/// [finder] can be scrolled to and tapped: nothing covers it.
Future<void> expectReachable(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}
