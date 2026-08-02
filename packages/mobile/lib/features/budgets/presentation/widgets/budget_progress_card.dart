import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/constants/budget_ui_tokens.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_progress_colors.dart';

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

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);
    onEdit();
  }

  void _handleDelete(BuildContext context) {
    Navigator.pop(context);
    onDelete();
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BudgetUiTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  PiconsRegular.pencilSimple,
                  color: BudgetUiTokens.textPrimary,
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(color: BudgetUiTokens.textPrimary),
                ),
                onTap: () => _handleEdit(context),
              ),
              ListTile(
                leading: const Icon(
                  PiconsRegular.trash,
                  color: BudgetUiTokens.error,
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: BudgetUiTokens.error),
                ),
                onTap: () => _handleDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
    final progressColor = budgetProgressColor(progress.percentage);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BudgetUiTokens.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    progress.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BudgetUiTokens.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${fmt.format(progress.spentAmount)} of ${fmt.format(progress.effectiveAmount)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: BudgetUiTokens.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: LinearProgressIndicator(
                  value: (progress.percentage / 100).clamp(0.0, 1.0),
                  backgroundColor: BudgetUiTokens.progressTrack,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
