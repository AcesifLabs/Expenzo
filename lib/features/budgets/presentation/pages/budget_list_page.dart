import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/navigation_utils.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: BlocConsumer<BudgetBloc, BudgetState>(
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
            if (state.budgets.isEmpty) {
              return const Center(
                child: Text('No budgets yet. Tap + to create one.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.budgets.length,
              itemBuilder: (context, index) {
                final budget = state.budgets[index];
                return BudgetProgressCard(
                  budget: budget,
                  onEdit: () => _navigateToEdit(context, budget),
                  onDelete: () => _confirmDelete(context, budget),
                );
              },
            );
          }

          return const Center(child: Text('Load budgets to see data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        child: const Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      SlidePageRoute(builder: (_) => const BudgetFormPage()),
    );

    if (result == true && context.mounted) {
      context.read<BudgetBloc>().add(LoadBudgets());
    }
  }

  void _navigateToEdit(BuildContext context, Budget budget) async {
    final result = await Navigator.push(
      context,
      SlidePageRoute(builder: (_) => BudgetFormPage(budget: budget)),
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
        content: Text(
          'Are you sure you want to delete "${budget.categoryId ?? 'Overall'}" budget?',
        ),
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
