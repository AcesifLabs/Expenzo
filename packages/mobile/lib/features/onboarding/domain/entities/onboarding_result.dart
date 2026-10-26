import 'package:equatable/equatable.dart';

class OnboardingResult extends Equatable {
  final int recurringCount;
  final bool budgetsCreated;
  final String? goalName;
  final bool hadErrors;

  @override
  List<Object?> get props => [
    recurringCount,
    budgetsCreated,
    goalName,
    hadErrors,
  ];

  const OnboardingResult({
    this.recurringCount = 0,
    this.budgetsCreated = false,
    this.goalName,
    this.hadErrors = false,
  });
}
