import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

import '../../domain/entities/goal.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import 'goal_progress_body.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      buildWhen: (a, b) => a.newest != b.newest || a.status != b.status,
      builder: (context, state) {
        final goal = state.newest;
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
          child: goal == null ? const _SetGoalPrompt() : _GoalCard(goal: goal),
        );
      },
    );
  }
}

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

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cardT = t.goals.card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardSectionHeader(
          title: cardT.section,
          onTrailingTap: () => context.push('/goals'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          hint: cardT.edit,
          child: AppCard(
            backgroundColor: palette.surfaceHigh,
            borderRadius: AppSpacing.radiusCard,
            padding: AppSpacing.paddingMd,
            onTap: () => context.push('/goals/${goal.id}/edit'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GoalProgressBody(goal: goal),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => context.push('/goals/new'),
                  icon: const Icon(PiconsRegular.plus),
                  label: Text(cardT.newGoal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
