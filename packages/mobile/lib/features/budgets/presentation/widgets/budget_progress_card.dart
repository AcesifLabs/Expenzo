import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  void _onMenuSelected(String value) {
    if (value == 'edit') onEdit();
    if (value == 'delete') onDelete();
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            progress.categoryId ?? 'Overall Budget',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: _onMenuSelected,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressInfo(NumberFormat fmt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${fmt.format(progress.spentAmount)} spent / ${fmt.format(progress.budgetAmount)} budget',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        if (progress.rolloverAmount > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Includes ${fmt.format(progress.rolloverAmount)} rollover',
            style: TextStyle(fontSize: 12, color: Colors.green[700]),
          ),
        ],
        const SizedBox(height: 12),
        BudgetProgressIndicator(percentage: progress.percentage),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.percentage.toStringAsFixed(0)}% used',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (progress.isOverBudget)
              Text(
                'OVER BUDGET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.expense,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildProgressInfo(fmt),
        ],
      ),
    );
  }
}
