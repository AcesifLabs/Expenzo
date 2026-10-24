import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import '../../domain/entities/my_group.dart';
import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_dashboard_helpers.dart';
import 'member_avatar_row.dart';
import 'member_spending_list.dart';
import 'shared_budget_progress_list.dart';
import 'spent_of_planned_card.dart';

/// Frame `FamilyDashboard`, from the server summary (ADR 0008). With
/// cached numbers it says when they were fetched.
class FamilyDashboardView extends StatelessWidget {
  final FamilyState state;
  final MyGroup group;

  /// The time now, replaced in tests.
  final DateTime Function() clock;

  const FamilyDashboardView({
    super.key,
    required this.state,
    required this.group,
    this.clock = DateTime.now,
  });

  void _retry(BuildContext context) =>
      context.read<FamilyBloc>().add(const FamilyRefreshRequested());

  Widget _buildSummary(BuildContext context) {
    final summary = state.summary?.value;
    if (summary != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpentOfPlannedCard(summary: summary),
          const SizedBox(height: AppSpacing.lg),
          MemberSpendingList(group: group, summary: summary),
          const SizedBox(height: AppSpacing.lg),
          SharedBudgetProgressList(summary: summary),
        ],
      );
    }
    if (state.summaryFailure != null) {
      return Column(
        children: [
          Text(
            t.family.dashboard.summaryFailed,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextButton.icon(
            icon: const Icon(PiconsRegular.arrowClockwise),
            label: Text(t.common.tryAgain),
            onPressed: () => _retry(context),
          ),
        ],
      );
    }

    return Column(
      children: [
        for (final height in const [180.0, 120.0, 120.0])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ShimmerBox.rectangle(
              width: double.infinity,
              height: height,
              borderRadius: AppSpacing.radiusCard,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final lastUpdated = state.lastUpdated;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.pagePadding,
      children: [
        if (lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              t.family.dashboard.lastUpdated(
                time: lastUpdatedLabel(
                  lastUpdated,
                  clock(),
                  LocaleSettings.currentLocale.languageCode,
                ),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        MemberAvatarRow(group: group),
        const SizedBox(height: AppSpacing.lg),
        _buildSummary(context),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
