import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/monthly_equivalent.dart';

void main() {
  double cents(double v) => (v * 100).roundToDouble() / 100;

  test('each frequency converts to a month', () {
    expect(cents(monthlyEquivalent(120, RecurringFrequency.daily)), 3650);
    expect(cents(monthlyEquivalent(120, RecurringFrequency.weekly)), 520);
    expect(monthlyEquivalent(120, RecurringFrequency.monthly), 120);
    expect(monthlyEquivalent(120, RecurringFrequency.yearly), 10);
  });
}
