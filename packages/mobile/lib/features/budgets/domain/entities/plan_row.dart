import 'package:equatable/equatable.dart';

class _PlanRowSentinel {
  const _PlanRowSentinel();
}

const _sentinel = _PlanRowSentinel();

/// One budget inside the Budget Plan editor. [key] stays stable while the
/// row is edited: the budget id for a loaded row, a fresh uuid otherwise.
class PlanRow extends Equatable {
  final String key;
  final String? budgetId;
  final String name;
  final double amount;
  final bool isSavings;

  @override
  List<Object?> get props => [key, budgetId, name, amount, isSavings];

  const PlanRow({
    required this.key,
    this.budgetId,
    required this.name,
    required this.amount,
    this.isSavings = false,
  });

  PlanRow copyWith({
    String? name,
    double? amount,
    Object? budgetId = _sentinel,
  }) {
    return PlanRow(
      key: key,
      budgetId: budgetId == _sentinel ? this.budgetId : budgetId as String?,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      isSavings: isSavings,
    );
  }
}
