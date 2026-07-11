import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';

class DashboardBudgetPreview extends Equatable {
  final BudgetProgress progress;
  final String title;
  final String? emoji;

  @override
  List<Object?> get props => [progress, title, emoji];

  const DashboardBudgetPreview({
    required this.progress,
    required this.title,
    this.emoji,
  });
}
