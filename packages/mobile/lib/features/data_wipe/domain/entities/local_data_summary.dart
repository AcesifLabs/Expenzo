import 'package:equatable/equatable.dart';

class LocalDataSummary extends Equatable {
  final int transactions;
  final int budgets;
  final int categories;
  final int recurring;

  final int smsRules;

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
