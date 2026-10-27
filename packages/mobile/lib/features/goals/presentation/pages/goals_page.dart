import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/goal.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../widgets/add_to_goal_sheet.dart';
import '../widgets/goal_progress_body.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.getIt<GoalBloc>()..add(const GoalWatchStarted()),
      child: const GoalsView(),
    );
  }
}

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  void _onStateChanged(BuildContext context, GoalState state) {
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    final error = state.errorText;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));

      return;
    }
    final goal = state.lastAddedTo;
    final added = state.lastAdded;
    if (goal == null || added == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          t.goals.added(
            amount: CurrencyFormatter.format(added),
            name: goal.name,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listT = t.goals.list;

    return Scaffold(
      body: AppScaffold(
        title: listT.title,
        subtitle: listT.subtitle,
        leading: const AppBackButton(),
        child: BlocConsumer<GoalBloc, GoalState>(
          listenWhen: (a, b) =>
              a.contributionCount != b.contributionCount ||
              (b.errorText != null && a.errorText != b.errorText),
          listener: _onStateChanged,
          builder: (context, state) => switch (state.status) {
            GoalStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            GoalStatus.error => AppErrorState(
              message: listT.loadFailed,
              onRetry: () =>
                  context.read<GoalBloc>().add(const GoalWatchStarted()),
            ),
            _ when state.goals.isEmpty => AppEmptyState(
              icon: PiconsRegular.target,
              message: listT.empty,
              actionLabel: t.goals.card.newGoal,
              onAction: () => context.push('/goals/new'),
            ),
            _ => ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.sm,
                AppSpacing.pageGutter,
                AppSpacing.xxl + AppSpacing.xl,
              ),
              itemCount: state.goals.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.smd),
              itemBuilder: (context, index) => _GoalTile(
                goal: state.goals[index],
                saving: state.status == GoalStatus.saving,
              ),
            ),
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_goal_fab',
        onPressed: () => context.push('/goals/new'),
        icon: const Icon(PiconsRegular.plus),
        label: Text(t.goals.card.newGoal),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final Goal goal;
  final bool saving;

  const _GoalTile({required this.goal, required this.saving});

  Future<void> _onAddTapped(BuildContext context) async {
    final goalId = goal.id;
    if (goalId == null) return;
    final bloc = context.read<GoalBloc>();
    final amount = await showAddToGoalSheet(context, goalName: goal.name);
    if (amount != null) {
      bloc.add(GoalContributionSubmitted(goalId: goalId, amount: amount));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardT = t.goals.card;

    return Semantics(
      hint: cardT.edit,
      child: AppCard(
        backgroundColor: context.palette.surfaceHigh,
        padding: AppSpacing.paddingMd,
        onTap: () => context.push('/goals/${goal.id}/edit'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GoalProgressBody(goal: goal),
            if (!goal.isReached) ...[
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: saving ? null : () => _onAddTapped(context),
                child: Text(cardT.addToGoal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
