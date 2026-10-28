import '../entities/recurring_frequency.dart';

const kDefaultFrequencyChoices = [
  RecurringFrequency.weekly,
  RecurringFrequency.monthly,
  RecurringFrequency.yearly,
];

RecurringFrequency defaultFrequencyFrom(String? stored) {
  final frequency = RecurringFrequency.values.asNameMap()[stored];

  return frequency != null && kDefaultFrequencyChoices.contains(frequency)
      ? frequency
      : RecurringFrequency.monthly;
}
