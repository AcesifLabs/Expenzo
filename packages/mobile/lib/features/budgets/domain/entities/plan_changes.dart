import 'package:equatable/equatable.dart';

import 'budget.dart';

/// What saving a Budget Plan writes: budgets to create, update and delete.
class PlanChanges extends Equatable {
  static const empty = PlanChanges(toCreate: [], toUpdate: [], toDelete: []);

  final List<Budget> toCreate;
  final List<Budget> toUpdate;
  final List<Budget> toDelete;

  bool get isEmpty => toCreate.isEmpty && toUpdate.isEmpty && toDelete.isEmpty;

  @override
  List<Object?> get props => [toCreate, toUpdate, toDelete];

  const PlanChanges({
    required this.toCreate,
    required this.toUpdate,
    required this.toDelete,
  });
}
