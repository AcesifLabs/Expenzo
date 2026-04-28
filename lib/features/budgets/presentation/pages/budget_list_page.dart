import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_summary_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/skeletons/budget_list_skeleton.dart';
import 'budget_form_page.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BudgetBloc>()..add(LoadBudgets()),
      child: const _BudgetListPageContent(),
    );
  }
}

class _BudgetListPageContent extends StatelessWidget {
  const _BudgetListPageContent();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is BudgetError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is BudgetLoading) {
          return const BudgetListSkeleton();
        }

        if (state is BudgetError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is BudgetLoaded) {
          return AppScaffold.slivers(
            title: 'Budgets',
            actions: [
              IconButton(
                icon: Icon(PhosphorIcons.plus(PhosphorIconsStyle.light)),
                color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                onPressed: () => _navigateToCreate(context),
              ),
            ],
            slivers: [
              // Summary card
              SliverToBoxAdapter(child: _buildSummaryCard(context, state, fmt)),
              // Budget list
              if (state.budgets.isEmpty)
                SliverToBoxAdapter(
                  child: const Padding(
                    padding: EdgeInsets.all(40),
                    child: AppEmptyState(
                      icon: Icons.inbox,
                      message: 'No budgets yet. Tap + to create one.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final budget = state.budgets[index];
                      return BudgetProgressCard(
                        budget: budget,
                        onEdit: () => _navigateToEdit(context, budget),
                        onDelete: () => _confirmDelete(context, budget),
                      );
                    }, childCount: state.budgets.length),
                  ),
                ),
            ],
          );
        }

        return const Center(child: Text('Load budgets to see data'));
      },
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
                      value: 0.35,
                      backgroundColor: Colors.white.withAlpha(25),
                      color: const Color(0xFF34C759),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.budgets.length} budgets active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(140),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _navigateToCreate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BudgetBloc>(),
          child: const BudgetFormPage(),
        ),
      ),
    );
    if (result == true && context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  void _navigateToEdit(BuildContext context, Budget budget) async {
    final result = await Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<BudgetBloc>(),
          child: BudgetFormPage(budget: budget),
        ),
      ),
    );
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
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BudgetBloc>().add(DeleteBudgetEvent(budget.id!));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
