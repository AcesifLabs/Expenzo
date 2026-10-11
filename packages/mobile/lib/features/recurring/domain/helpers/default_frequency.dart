import '../entities/recurring_frequency.dart';

/// The frequencies offered as a default on the Recurring screen.
const kDefaultFrequencyChoices = [
  RecurringFrequency.weekly,
  RecurringFrequency.monthly,
  RecurringFrequency.yearly,
];

/// Parses `UserSettings.defaultRecurringFrequency`; anything else
/// (null, 'daily', unknown) falls back to monthly.
RecurringFrequency defaultFrequencyFrom(String? stored) {
  final frequency = RecurringFrequency.values.asNameMap()[stored];

  return frequency != null && kDefaultFrequencyChoices.contains(frequency)
      ? frequency
      : RecurringFrequency.monthly;
}
