import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

import '../../domain/entities/goal.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import 'add_to_goal_sheet.dart';

/// The dashboard's active goal with "Add to goal" (ADR 0009), or a prompt to
/// set one. It owns its data; the dashboard only places it.
class DashboardGoalCard extends StatelessWidget {
  const DashboardGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: di.featureDependenciesReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return const SizedBox.shrink();
        }

        return BlocProvider(
          create: (_) => di.getIt<GoalBloc>()..add(const GoalWatchStarted()),
          child: const _GoalCardView(),
        );
      },
    );
  }
}

class _GoalCardView extends StatelessWidget {
  const _GoalCardView();

  void _onStateChanged(BuildContext context, GoalState state) {
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    final error = state.errorText;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));

      return;
    }
    final goal = state.goal;
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
    return BlocConsumer<GoalBloc, GoalState>(
      listenWhen: (a, b) =>
          a.contributionCount != b.contributionCount ||
          (b.errorText != null && a.errorText != b.errorText),
      listener: _onStateChanged,
      builder: (context, state) {
        final goal = state.goal;
        if (state.status == GoalStatus.loading ||
            state.status == GoalStatus.error) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            0,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: goal == null
              ? const _SetGoalPrompt()
              : _GoalCard(
                  goal: goal,
                  saving: state.status == GoalStatus.saving,
                ),
        );
      },
    );
  }
}

/// No goal yet (Task 22b): always shown, no dismiss.
class _SetGoalPrompt extends StatelessWidget {
  const _SetGoalPrompt();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      child: AppCard(
        backgroundColor: palette.surfaceHigh,
        borderRadius: AppSpacing.radiusCard,
        padding: AppSpacing.paddingMd,
        onTap: () => context.push('/goals/new'),
        child: Row(
          children: [
            Icon(PiconsRegular.target, color: palette.accent),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                t.goals.card.setGoal,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(PiconsRegular.plus, color: palette.accent),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final bool saving;

  const _GoalCard({required this.goal, required this.saving});

  Future<void> _onAddTapped(BuildContext context) async {
    final bloc = context.read<GoalBloc>();
    final amount = await showAddToGoalSheet(context, goalName: goal.name);
    if (amount != null) bloc.add(GoalContributionSubmitted(amount));
  }

  String? _status() {
    final cardT = t.goals.card;
    if (goal.isReached) return cardT.reached;
    final months = goal.monthsLeft(DateTime.now());
    if (months == null) return null;

    return months > 0 ? cardT.monthsLeft(n: months) : cardT.dueThisMonth;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final cardT = t.goals.card;
    final status = _status();
    final monthly = goal.monthlyContribution;
    final secondary = textTheme.bodySmall?.copyWith(
      color: palette.textSecondary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(title: cardT.section),
        Semantics(
          hint: cardT.edit,
          child: AppCard(
            backgroundColor: palette.surfaceHigh,
            borderRadius: AppSpacing.radiusCard,
            padding: AppSpacing.paddingMd,
            onTap: () => context.push('/goals/${goal.id}/edit'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.name, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cardT.progress(
                    saved: CurrencyFormatter.format(goal.savedAmount),
                    target: CurrencyFormatter.format(goal.targetAmount),
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    color: palette.brand,
                    backgroundColor: palette.progressTrack,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    status,
                    style: goal.isReached
                        ? textTheme.bodySmall?.copyWith(color: palette.brand)
                        : textTheme.bodySmall,
                  ),
                ],
                if (monthly != null && !goal.isReached)
                  Text(
                    cardT.plan(amount: CurrencyFormatter.format(monthly)),
                    style: secondary,
                  ),
                if (!goal.isReached) ...[
                  const SizedBox(height: AppSpacing.md),
                  _AddButton(
                    saving: saving,
                    onPressed: () => _onAddTapped(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;

  const _AddButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? const SizedBox.square(
              dimension: AppSpacing.md,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(t.goals.card.addToGoal),
    );
  }
}
