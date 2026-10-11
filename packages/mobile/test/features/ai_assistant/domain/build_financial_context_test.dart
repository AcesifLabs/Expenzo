import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/theme/currency_config.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/build_financial_context.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/redact_ai_context.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_insights.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class _MockSummary extends Mock implements GetDashboardSummary {}

class _MockBreakdown extends Mock implements GetCategoryBreakdown {}

class _MockInsights extends Mock implements GetSpendingInsights {}

void main() {
  late _MockSummary summary;
  late BuildFinancialContext build;

  setUpAll(
    () => registerFallbackValue(
      const DateRange(preset: DateRangePreset.thisMonth),
    ),
  );

  setUp(() {
    summary = _MockSummary();
    final breakdown = _MockBreakdown();
    final insights = _MockInsights();
    when(
      () => breakdown(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'none')));
    when(
      () => insights(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
      ),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'none')));
    build = BuildFinancialContext(
      getDashboardSummary: summary,
      getSpendingInsights: insights,
      getCategoryBreakdown: breakdown,
      redactAiContext: const RedactAiContext(),
    );
  });

  tearDown(
    () => CurrencyFormatter.current.value = CurrencyConfig.byCode(
      CurrencyConfig.defaultCode,
    ),
  );

  void summaryWith({double? percentChange}) {
    when(() => summary(any())).thenAnswer(
      (_) async => Right(
        DashboardSummary(
          totalIncome: 5000,
          totalExpense: 1200,
          totalSpent: 1200,
          previousPeriodTotal: 1000,
          percentChange: percentChange,
          categoryBreakdown: const [],
          recentTransactions: const [],
        ),
      ),
    );
  }

  Future<String> prompt() async =>
      (await build()).getOrElse(() => fail('expected a prompt'));

  test('states net, and the change when there is an earlier period', () async {
    summaryWith(percentChange: 20);

    final text = await prompt();

    expect(text, contains('Net (income − expense): 3800.00'));
    expect(text, contains('Spending change vs previous period: 20.0%'));
  });

  test('says so when there was no spending before, instead of 0%', () async {
    summaryWith();

    expect(await prompt(), contains('no spending in the previous period'));
  });

  test("names the user's currency", () async {
    CurrencyFormatter.current.value = CurrencyConfig.byCode('EUR');
    summaryWith(percentChange: 0);

    expect(await prompt(), contains('Currency: EUR (Euro)'));
  });

  test('asks the model to reply in the app language', () async {
    summaryWith(percentChange: 0);
    expect(await prompt(), contains('Reply in English.'));

    LocaleSettings.setLocaleSync(AppLocale.bn);
    addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));
    expect(await prompt(), contains('Reply in Bangla (Bengali script).'));
  });
}
