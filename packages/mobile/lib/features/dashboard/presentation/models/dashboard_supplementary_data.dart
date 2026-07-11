import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/dashboard/presentation/models/dashboard_budget_preview.dart';

class DashboardSupplementaryData extends Equatable {
  final List<DashboardBudgetPreview> budgetPreviews;
  final Map<String, Category> categoriesById;

  const DashboardSupplementaryData({
    required this.budgetPreviews,
    required this.categoriesById,
  });

  static const empty = DashboardSupplementaryData(
    budgetPreviews: [],
    categoriesById: {},
  );

  @override
  List<Object?> get props => [budgetPreviews, categoriesById];
}
