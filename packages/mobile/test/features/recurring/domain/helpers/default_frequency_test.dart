import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/default_frequency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stored weekly, monthly and yearly map to their frequencies', () {
    expect(defaultFrequencyFrom('weekly'), RecurringFrequency.weekly);
    expect(defaultFrequencyFrom('monthly'), RecurringFrequency.monthly);
    expect(defaultFrequencyFrom('yearly'), RecurringFrequency.yearly);
  });

  test('nothing stored falls back to monthly', () {
    expect(defaultFrequencyFrom(null), RecurringFrequency.monthly);
  });

  test('daily is not offered as a default and falls back to monthly', () {
    expect(defaultFrequencyFrom('daily'), RecurringFrequency.monthly);
  });

  test('an unknown value falls back to monthly', () {
    expect(defaultFrequencyFrom('nonsense'), RecurringFrequency.monthly);
  });

  test('the choices are weekly, monthly, yearly in that order', () {
    expect(kDefaultFrequencyChoices, [
      RecurringFrequency.weekly,
      RecurringFrequency.monthly,
      RecurringFrequency.yearly,
    ]);
  });
}
