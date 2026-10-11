import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/ai_assistant/domain/constants/ai_assistant.constants.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/redact_ai_context.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_spending_insights.dart';
import 'package:expense_tracker/features/reports/domain/usecases/get_category_breakdown.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class BuildFinancialContext {
  final GetDashboardSummary getDashboardSummary;
  final GetSpendingInsights getSpendingInsights;
  final GetCategoryBreakdown getCategoryBreakdown;
  final RedactAiContext redactAiContext;

  const BuildFinancialContext({
    required this.getDashboardSummary,
    required this.getSpendingInsights,
    required this.getCategoryBreakdown,
    required this.redactAiContext,
  });

  Future<Either<Failure, String>> call() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = now;

    final summaryResult = await getDashboardSummary(
      const DateRange(preset: DateRangePreset.thisMonth),
    );

    return summaryResult.fold((failure) => Left(failure), (summary) async {
      final buffer = _buildSummarySection(summary);

      await _appendCategorySection(buffer, startDate, endDate);
      await _appendInsightsSection(buffer, startDate, endDate);

      final currency = CurrencyFormatter.current.value;
      buffer.writeln();
      buffer.writeln(
        'Currency: ${currency.code} (${currency.name}). Always mention currency when discussing amounts.',
      );
      buffer.writeln(
        'Answer concisely. Use the data above — do not guess or invent numbers.',
      );
      buffer.writeln('Reply in ${_replyLanguage()}.');

      return Right(redactAiContext(buffer.toString()));
    });
  }

  StringBuffer _buildSummarySection(DashboardSummary summary) {
    final buffer = StringBuffer();
    buffer.writeln(AiAssistantConstants.systemGuardrails.trim());
    buffer.writeln();
    buffer.writeln('## User Financial Data (this month)');
    buffer.writeln();
    buffer.writeln(
      '- Total income (IN records): ${summary.totalIncome.toStringAsFixed(2)}',
    );
    buffer.writeln(
      '- Total expense (OUT records / spending): ${summary.totalExpense.toStringAsFixed(2)}',
    );
    buffer.writeln(
      '- Net (income − expense): ${summary.net.toStringAsFixed(2)}',
    );
    buffer.writeln(
      '- Spending change vs previous period: ${_describeChange(summary.percentChange)}',
    );

    if (summary.recentTransactions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Recent Transactions (examples of IN vs OUT)');
      for (final r in summary.recentTransactions.take(5)) {
        final type = r.recordType.name;
        final sign = type == 'income' ? '+' : '-';
        buffer.writeln(
          '  - [$type] $sign${r.amount.toStringAsFixed(2)} — ${r.description} (${r.date.toIso8601String().substring(0, 10)})',
        );
      }
    }

    return buffer;
  }

  Future<void> _appendCategorySection(
    StringBuffer buffer,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await getCategoryBreakdown(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold((_) => null, (categories) {
      if (categories.isEmpty) return;

      buffer.writeln('## Top Spending Categories (expense/OUT only)');
      for (final cat in categories.take(5)) {
        buffer.writeln(
          '  - ${cat.categoryName}: ${cat.amount.toStringAsFixed(2)} (${cat.percentage.toStringAsFixed(1)}%)',
        );
      }
    });
  }

  Future<void> _appendInsightsSection(
    StringBuffer buffer,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await getSpendingInsights(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold((_) => null, (insights) {
      buffer.writeln('## Spending Insights (expense/OUT data)');
      buffer.writeln(
        '  - Average daily spending: ${insights.avgDailySpending.toStringAsFixed(2)}',
      );
      if (insights.highestDayDate != null) {
        buffer.writeln(
          '  - Highest spending day amount: ${insights.highestDayAmount.toStringAsFixed(2)}',
        );
      }
      buffer.writeln(
        '  - Total transaction count (IN+OUT): ${insights.totalTransactionCount}',
      );
    });
  }

  // percentChange is already a percentage; null means no earlier spending.
  String _describeChange(double? percentChange) {
    if (percentChange == null) return 'no spending in the previous period';

    return '${percentChange.toStringAsFixed(1)}%';
  }

  /// The app language, named for the model.
  String _replyLanguage() => switch (LocaleSettings.currentLocale) {
    AppLocale.bn => 'Bangla (Bengali script)',
    AppLocale.en => 'English',
  };
}
