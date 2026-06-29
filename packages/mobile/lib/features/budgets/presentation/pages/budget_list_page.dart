import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_summary_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/skeletons/budget_list_skeleton.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<BudgetBloc>()..add(LoadBudgets()),
      child: const BudgetListView(),
    );
  }
}

class BudgetListView extends StatefulWidget {
  const BudgetListView({super.key});

  @override
  State<BudgetListView> createState() => _BudgetListViewState();
}

class _BudgetListViewState extends State<BudgetListView> {
  void _onStateChanged(BuildContext context, BudgetState state) {
    switch (state) {
      case BudgetOperationSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Budget operation successful')),
        );
      case BudgetError(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  BudgetProgress? _findProgress(BudgetLoaded state, Budget budget) {
    final id = budget.id;
    if (id == null) return null;

    return state.progressByBudgetId[id];
  }

  Color _getIndicatorColor(double percentage) {
    if (percentage > 100) {
      return AppColors.expense;
    }
    if (percentage >= 80) {
      return AppColors.warning;
    }

    return AppColors.success;
  }

  Widget _buildLoadedState(
    BuildContext context,
    BudgetLoaded state,
    NumberFormat fmt,
  ) {
    return AppScaffold.slivers(
      title: 'Budgets',
      actions: [
        IconButton(
          icon: const Icon(PiconsLight.plus),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
          onPressed: () => _navigateToCreate(context),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(child: _buildSummaryCard(context, state, fmt)),

        if (state.budgets.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: AppEmptyState(
                icon: PiconsRegular.tray,
                message: 'No budgets yet. Tap + to create one.',
              ),
            ),
          )
        else
          _buildBudgetList(state),
      ],
    );
  }

  Widget _buildBudgetList(BudgetLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final budget = state.budgets[index];
          final progress = _findProgress(state, budget);

          final displayProgress =
              progress ??
              BudgetProgress(
                budgetId: budget.id ?? '',
                budgetAmount: budget.amount,
                effectiveAmount:
                    budget.amount +
                    (budget.rolloverEnabled ? budget.rolloverAmount : 0),
                spentAmount: 0,
                rolloverAmount: budget.rolloverAmount,
                percentage: 0,
                isOverBudget: false,
                categoryId: budget.categoryId,
                periodRange: DateTimeRange(
                  start: budget.startDate,
                  end: budget.startDate,
                ),
                period: budget.period,
              );

          return BudgetProgressCard(
            progress: displayProgress,
            onTap: () => _navigateToDetails(context, displayProgress),
            onEdit: () => _navigateToEdit(context, budget),
            onDelete: () => _confirmDelete(context, budget),
          );
        }, childCount: state.budgets.length),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    BudgetLoaded state,
    NumberFormat fmt,
  ) {
    final totalBudget = state.budgets.fold<double>(
      0,
      (sum, b) => sum + b.amount,
    );
    final totalSpent = state.progressByBudgetId.values.fold<double>(
      0,
      (sum, p) => sum + p.spentAmount,
    );
    final overallPercentage = totalBudget > 0
        ? (totalSpent / totalBudget) * 100
        : 0.0;
    final colorScheme = Theme.of(context).colorScheme;

    final indicatorColor = _getIndicatorColor(overallPercentage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AppSummaryCard(
        title: 'Monthly Spending',
        value: fmt.format(totalBudget),
        bottomChild: state.budgets.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (overallPercentage / 100).clamp(0.0, 1.0),
                      backgroundColor: colorScheme.onSurface.withAlpha(25),
                      color: indicatorColor,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.budgets.length} budgets active',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _navigateToDetails(BuildContext context, BudgetProgress progress) {
    context.push('/budgets/${progress.budgetId}');
  }

  Future<void> _navigateToCreate(BuildContext context) async {
    final result = await context.push<bool>('/budgets/new');
    if (result == true && context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  Future<void> _navigateToEdit(BuildContext context, Budget budget) async {
    final result = await context.push<bool>('/budgets/${budget.id}/edit');
    if (result == true && context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  void _confirmDelete(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Delete "${budget.categoryId ?? 'Overall'}" budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _onConfirmDelete(dialogContext, context, budget),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onConfirmDelete(
    BuildContext dialogContext,
    BuildContext pageContext,
    Budget budget,
  ) {
    if (dialogContext.mounted) Navigator.pop(dialogContext);
    pageContext.read<BudgetBloc>().add(DeleteBudgetEvent(budget.id ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = CurrencyFormatter.getFormatter(decimalDigits: 0);

    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return switch (state) {
          BudgetLoading() => const BudgetListSkeleton(),
          BudgetError(:final message) => Center(child: Text('Error: $message')),
          BudgetLoaded() => _buildLoadedState(context, state, fmt),
          _ => const Center(child: Text('Load budgets to see data')),
        };
      },
    );
  }
}
