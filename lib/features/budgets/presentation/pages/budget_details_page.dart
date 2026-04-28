import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';

/// Full-screen detail view for a single budget, showing its transactions.
class BudgetDetailsPage extends StatelessWidget {
  final BudgetProgress progress;

  const BudgetDetailsPage({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(progress.categoryId ?? 'Budget Details'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.light)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Budget summary header
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${fmt.format(progress.spentAmount)} / ${fmt.format(progress.budgetAmount)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.period.name} budget',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withAlpha(140),
                  ),
                ),
                const SizedBox(height: 16),
                BudgetProgressIndicator(percentage: progress.percentage),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progress.percentage.toStringAsFixed(0)}% used',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurface.withAlpha(120),
                      ),
                    ),
                    if (progress.isOverBudget)
                      Text(
                        'OVER BUDGET',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.listDashes(PhosphorIconsStyle.light),
                  size: 18,
                  color: colors.onSurface.withAlpha(120),
                ),
                const SizedBox(width: 8),
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Transaction list
          Expanded(
            child: FutureBuilder<List<Record>>(
              future: di.getIt<GetBudgetTransactions>()(progress.budgetId)
                  .then((r) => r.getOrElse(() => [])),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return BudgetTransactionList(
                  records: snapshot.data ?? [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
