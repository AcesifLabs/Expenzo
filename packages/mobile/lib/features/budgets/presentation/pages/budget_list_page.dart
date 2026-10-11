import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/services/notification_permission.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/domain/usecases/get_budget_progress.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/skeletons/budget_list_skeleton.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class BudgetListPage extends StatelessWidget {
  const BudgetListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<BudgetBloc>()..add(const LoadBudgets()),
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
  AppPalette get _palette => context.palette;

  /// Ask for notification permission at most once per app run, and only
  /// once there is a budget to be alerted about.
  static bool _askedForAlertPermission = false;

  void _onStateChanged(BuildContext context, BudgetState state) {
    if (state is BudgetLoaded &&
        state.budgets.isNotEmpty &&
        !_askedForAlertPermission) {
      _askedForAlertPermission = true;
      unawaited(requestBudgetAlertPermissionIfNeeded());
    }
    switch (state) {
      case BudgetOperationSuccess():
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(t.budgets.saved)));
      case BudgetError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return AppPageHeader(
      title: t.budgets.title,
      subtitle: t.budgets.subtitle,
      actions: [
        // Labelled so it isn't confused with the add-transaction button.
        TextButton.icon(
          icon: const Icon(PiconsRegular.plus, size: 18),
          label: Text(t.common.newBudget),
          onPressed: () => _navigateToCreate(context),
        ),
      ],
    );
  }

  BudgetProgress? _findProgress(BudgetLoaded state, Budget budget) {
    final id = budget.id;
    if (id == null) return null;

    return state.progressByBudgetId[id];
  }

  Future<void> _onRefresh() {
    context.read<BudgetBloc>().add(const LoadBudgets());

    return Future<void>.value();
  }

  Widget _buildLoadedState(BuildContext context, BudgetLoaded state) {
    final textTheme = Theme.of(context).textTheme;
    final emptyStrings = t.budgets.empty;

    return Scaffold(
      backgroundColor: _palette.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (state.budgets.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emptyStrings.title, style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          emptyStrings.body,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: _palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          icon: const Icon(PiconsRegular.plus, size: 18),
                          label: Text(t.common.newBudget),
                          onPressed: () => _navigateToCreate(context),
                        ),
                      ],
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
      context.read<BudgetBloc>().add(const LoadBudgets());
    }
  }

  Future<void> _navigateToEdit(BuildContext context, Budget budget) async {
    final result = await context.push<bool>('/budgets/${budget.id}/edit');
    if (result == true && context.mounted) {
      context.read<BudgetBloc>().add(const LoadBudgets());
    }
  }

  void _confirmDelete(BuildContext context, Budget budget) {
    final strings = t.budgets.delete;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.title),
        content: Text(strings.confirm(name: budget.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => _onConfirmDelete(dialogContext, context, budget),
            child: Text(t.common.delete),
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
          BudgetLoading() => Scaffold(
            backgroundColor: _palette.bg,
            body: const BudgetListSkeleton(),
          ),
          BudgetError(:final message) => Scaffold(
            backgroundColor: _palette.bg,
            body: Center(child: Text(message)),
          ),
          BudgetLoaded() => _buildLoadedState(context, state),
          _ => Scaffold(
            backgroundColor: _palette.bg,
            body: Center(child: Text(t.budgets.loadPrompt)),
          ),
        };
      },
    );
  }
}
