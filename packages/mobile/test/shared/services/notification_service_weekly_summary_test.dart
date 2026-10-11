import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/reports/domain/entities/weekly_summary.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/notification_service.dart';

WeeklySummary _summary(double thisWeek, double lastWeek) => WeeklySummary(
  thisWeekTotal: thisWeek,
  lastWeekTotal: lastWeek,
  weekStart: DateTime(2026, 10, 12),
);

void main() {
  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  final amount = CurrencyFormatter.format(1500);
  String body(double thisWeek, double lastWeek) =>
      NotificationService.weeklySummaryBody(_summary(thisWeek, lastWeek));

  test('more than last week', () {
    expect(
      body(1500, 1000),
      'You spent $amount this week, 50% more than last week.',
    );
  });

  test('less than last week', () {
    expect(
      body(1500, 2000),
      'You spent $amount this week, 25% less than last week.',
    );
  });

  test('a change that rounds to 0% reads as the same', () {
    expect(
      body(1500, 1501),
      'You spent $amount this week, the same as last week.',
    );
  });

  test('nothing last week has no comparison', () {
    expect(body(1500, 0), 'You spent $amount this week.');
  });

  test('nothing this week', () {
    expect(body(0, 300), 'No spending recorded this week.');
  });

  test('reads in Bangla', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);

    expect(
      body(1500, 1000),
      'এই সপ্তাহে আপনি ${CurrencyFormatter.format(1500)} খরচ করেছেন, '
      'গত সপ্তাহের চেয়ে 50% বেশি।',
    );
  });
}
