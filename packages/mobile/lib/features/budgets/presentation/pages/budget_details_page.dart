import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_transactions.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_progress_indicator.dart';
import 'package:expense_tracker/shared/presentation/widgets/budget_transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Full-screen detail view for a single budget, showing its transactions.
class BudgetDetailsPage extends StatefulWidget {
  final BudgetProgress progress;

  const BudgetDetailsPage({super.key, required this.progress});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  String _categoryName = '';

  @override
  void initState() {
    super.initState();
    _loadCategoryName();
  }

  Future<void> _loadCategoryName() async {
    final catId = widget.progress.categoryId;
    if (catId == null) return;
    final intId = int.tryParse(catId);
    if (intId == null) return;
    try {
      final result =
          await di.getIt<CategoryRepository>().getCategoryById(intId);
      if (mounted) {
        final name = result.fold((_) => '', (cat) => cat.name);
        setState(() => _categoryName = name);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final colors = Theme.of(context).colorScheme;
    final title = _categoryName.isNotEmpty
        ? _categoryName
        : (widget.progress.categoryId ?? 'Budget Details');

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
                  BudgetProgressIndicator(percentage: widget.progress.percentage),
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
          // Transaction list
          Expanded(
            child: FutureBuilder<List<Record>>(
              future: di.getIt<GetBudgetTransactions>()(widget.progress.budgetId)
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
