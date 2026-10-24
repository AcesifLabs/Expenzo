import 'package:equatable/equatable.dart';

/// How much Delete all data will erase on this device.
class LocalDataSummary extends Equatable {
  final int transactions;
  final int budgets;
  final int categories;
  final int recurring;

  /// SMS Formats plus Matching Rules.
  final int smsRules;

  /// Null when no goals sync handler is registered; the row is hidden then.
  final int? goals;

  @override
  List<Object?> get props => [
    transactions,
    budgets,
    categories,
    recurring,
    smsRules,
    goals,
  ];

  const LocalDataSummary({
    required this.transactions,
    required this.budgets,
    required this.categories,
    required this.recurring,
    required this.smsRules,
    this.goals,
  });
}
