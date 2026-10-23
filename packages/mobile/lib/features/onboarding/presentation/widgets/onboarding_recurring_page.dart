import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/onboarding_plan.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import 'onboarding_page_frame.dart';
import 'recurring_draft_sheet.dart';

/// Step 2 (frame `OnboardingRecurring`): fixed expenses. None is a valid
/// answer, so Continue is always on.
class OnboardingRecurringPage extends StatelessWidget {
  const OnboardingRecurringPage({super.key});

  Future<void> _add(BuildContext context) async {
    final bloc = context.read<OnboardingBloc>();
    final item = await showRecurringDraftSheet(context);
    if (item != null) bloc.add(RecurringItemAdded(item));
  }

  Widget _row(BuildContext context, RecurringDraft item, int index) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: palette.surfaceHigh,
      borderRadius: AppSpacing.radiusCard,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        0,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(PiconsRegular.repeat, color: palette.accent),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.description} · ${CurrencyFormatter.format(item.amount)}',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  item.frequency.displayName,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(PiconsRegular.trash, color: palette.textSecondary),
            tooltip: t.onboarding.recurring.remove(name: item.description),
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTapTarget,
              minHeight: AppSpacing.minTapTarget,
            ),
            onPressed: () =>
                context.read<OnboardingBloc>().add(RecurringItemRemoved(index)),
          ),
        ],
      ),
    );
  }

  Widget _total(BuildContext context, List<RecurringDraft> items) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final recurringT = t.onboarding.recurring;

    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              recurringT.total,
              style: textTheme.bodySmall?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
          Text(
            t.onboarding.income.perMonth(
              amount: CurrencyFormatter.format(recurringMonthlyTotal(items)),
            ),
            style: textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recurringT = t.onboarding.recurring;
    final accent = context.palette.accent;
    final items = context.select<OnboardingBloc, List<RecurringDraft>>(
      (bloc) => bloc.state.pendingRecurring,
    );

    return OnboardingPageFrame(
      title: recurringT.title,
      subtitle: recurringT.subtitle,
      onContinue: () =>
          context.read<OnboardingBloc>().add(const RecurringSubmitted()),
      body: [
        for (final (index, item) in items.indexed) ...[
          _row(context, item, index),
          const SizedBox(height: AppSpacing.sm),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _add(context),
            icon: Icon(PiconsRegular.plus, color: accent),
            label: Text(
              items.isEmpty ? recurringT.addFirst : recurringT.addAnother,
              style: TextStyle(color: accent),
            ),
          ),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _total(context, items),
        ],
      ],
    );
  }
}
