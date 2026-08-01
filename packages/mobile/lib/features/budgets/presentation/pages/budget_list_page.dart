import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../constants/budget_ui_tokens.dart';
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Budgets',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: BudgetUiTokens.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Track your monthly limits',
                style: TextStyle(
                  fontSize: 13,
                  color: BudgetUiTokens.textTertiary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              PiconsLight.plus,
              color: BudgetUiTokens.textPrimary,
            ),
            tooltip: 'Add Budget',
            onPressed: () => _navigateToCreate(context),
          ),
        ],
      ),
    );
  }

  BudgetProgress? _findProgress(BudgetLoaded state, Budget budget) {
    final id = budget.id;
    if (id == null) return null;

    return state.progressByBudgetId[id];
  }

  Future<void> _onRefresh() {
    context.read<BudgetBloc>().add(LoadBudgets());

    return Future<void>.value();
  }

  Widget _buildLoadedState(BuildContext context, BudgetLoaded state) {
    return Scaffold(
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (state.budgets.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No Budgets Present',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: BudgetUiTokens.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                _buildBudgetList(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetList(BudgetLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                name: budget.name,
                periodRange: DateTimeRange(
                  start: budget.startDate,
                  end: budget.startDate,
                ),
                period: budget.period,
              );

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BudgetProgressCard(
              progress: displayProgress,
              onTap: () => _navigateToDetails(context, displayProgress),
              onEdit: () => _navigateToEdit(context, budget),
              onDelete: () => _confirmDelete(context, budget),
            ),
          );
        }, childCount: state.budgets.length),
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
        content: Text('Delete "${budget.name}" budget?'),
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
    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: _onStateChanged,
      builder: (context, state) {
        return switch (state) {
          BudgetLoading() => const Scaffold(
            backgroundColor: BudgetUiTokens.bg,
            body: BudgetListSkeleton(),
          ),
          BudgetError(:final message) => Scaffold(
            backgroundColor: BudgetUiTokens.bg,
            body: Center(child: Text('Error: $message')),
          ),
          BudgetLoaded() => _buildLoadedState(context, state),
          _ => const Scaffold(
            backgroundColor: BudgetUiTokens.bg,
            body: Center(child: Text('Load budgets to see data')),
          ),
        };
      },
    );
  }
}
