import '../entities/recurring_frequency.dart';

double monthlyEquivalent(double amount, RecurringFrequency frequency) =>
    switch (frequency) {
      RecurringFrequency.daily => amount * 365 / 12,
      RecurringFrequency.weekly => amount * 52 / 12,
      RecurringFrequency.monthly => amount,
      RecurringFrequency.yearly => amount / 12,
    };
