import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

/// Full-screen detail view for a single budget, showing its transactions.
class BudgetDetailsPage extends StatefulWidget {
  final BudgetProgress progress;

  const BudgetDetailsPage({super.key, required this.progress});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<BudgetBloc>()
          .add(LoadBudgetTransactions(widget.progress.budgetId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);
    final colors = Theme.of(context).colorScheme;
    final title = widget.progress.categoryId ?? 'Budget Details';

    return AppScaffold(
      title: title,
      child: Column(
        children: [
          // Budget summary header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${fmt.format(widget.progress.spentAmount)} / ${fmt.format(widget.progress.budgetAmount)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.progress.period.name} budget',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BudgetProgressIndicator(
                    percentage: widget.progress.percentage,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.progress.percentage.toStringAsFixed(0)}% used',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurface.withAlpha(120),
                        ),
                      ),
                      if (widget.progress.isOverBudget)
                        Text(
                          'OVER BUDGET',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.error,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Section label
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
          // Transaction list from Bloc state
          Expanded(
            child: BlocBuilder<BudgetBloc, BudgetState>(
              builder: (context, state) {
                if (state is BudgetLoaded &&
                    state.selectedBudgetId == widget.progress.budgetId) {
                  if (state.isLoadingTransactions) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return BudgetTransactionList(
                    records: state.selectedBudgetTransactions,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}