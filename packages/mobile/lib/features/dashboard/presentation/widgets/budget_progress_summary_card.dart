import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';

class BudgetProgressSummaryCard extends StatelessWidget {
  final BudgetProgress progress;
  final NumberFormat currencyFmt;
  final VoidCallback onTap;

  const BudgetProgressSummaryCard({
    super.key,
    required this.progress,
    required this.currencyFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spent = currencyFmt.format(progress.spentAmount);
    final budget = currencyFmt.format(progress.budgetAmount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Budget name (from categoryId for now)
                  Expanded(
                    child: Text(
                      progress.categoryId ?? 'Overall Budget',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  // Spent vs Budget
                  Text(
                    '$spent / $budget',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface.withAlpha(180),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              BudgetProgressIndicator(percentage: progress.percentage),
              const SizedBox(height: 4),
              // Percentage text
              Text(
                '${progress.percentage.toStringAsFixed(0)}% used',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurface.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}