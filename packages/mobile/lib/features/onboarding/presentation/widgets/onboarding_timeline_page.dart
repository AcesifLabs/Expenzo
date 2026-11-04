import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/onboarding_plan.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import 'onboarding_page_frame.dart';
import 'setup_complete_card.dart';

class OnboardingTimelinePage extends StatelessWidget {
  const OnboardingTimelinePage({super.key});

  Future<void> _pickDate(BuildContext context, GoalDraft goal) async {
    final bloc = context.read<OnboardingBloc>();
    final now = clock.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.customDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );

    if (picked != null) bloc.add(TimelineChosen(customDate: picked));
  }

  List<Widget> _options(BuildContext context, GoalDraft goal) {
    final options = timelineOptions(target: goal.targetAmount);
    final custom = goal.customDate;
    final customOption = custom == null
        ? null
        : customTimeline(
            target: goal.targetAmount,
            from: clock.now(),
            date: custom,
          );
    final bloc = context.read<OnboardingBloc>();
    final timelineT = t.onboarding.timeline;

    return [
      for (final option in options) ...[
        _TimelineCard(
          title: timelineT.months(n: option.months),
          option: option,
          selected: custom == null && goal.months == option.months,
          onTap: () => bloc.add(TimelineChosen(months: option.months)),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
      _TimelineCard(
        title: customOption == null
            ? timelineT.custom
            : '${timelineT.custom} · ${timelineT.months(n: customOption.months)}',
        subtitle: customOption == null ? timelineT.customHint : null,
        option: customOption,
        selected: customOption != null,
        onTap: () => _pickDate(context, goal),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingBloc>().state;
    final draft = state.draft;
    final goal = draft.goal;
    final chosen =
        goal == null || goal.months != null || goal.customDate != null;
    final saving = state.status == OnboardingStatus.saving;

    return OnboardingPageLayout(
      title: goal == null
          ? t.onboarding.complete.title
          : t.onboarding.timeline.title,
      body: [
        if (goal != null) ..._options(context, goal),
        if (chosen) ...[
          const SizedBox(height: AppSpacing.md),
          SetupCompleteCard(draft: draft),
        ],
      ],
      bottom: _FinishButton(
        saving: saving,
        onPressed: chosen && !saving
            ? () =>
                  context.read<OnboardingBloc>().add(const OnboardingFinished())
            : null,
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TimelineOption? option;
  final bool selected;
  final VoidCallback onTap;

  const _TimelineCard({
    required this.title,
    this.subtitle,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final option = this.option;
    final detail =
        subtitle ??
        (option == null
            ? null
            : t.onboarding.timeline.perMonth(
                amount: CurrencyFormatter.format(option.monthlyAmount),
              ));

    return Semantics(
      selected: selected,
      button: true,
      child: AppCard(
        backgroundColor: palette.surfaceHigh,
        borderRadius: AppSpacing.radiusCard,
        borderColor: selected ? palette.brand : null,
        padding: AppSpacing.paddingMd,
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.bodyLarge),
              if (detail != null)
                Text(
                  detail,
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  final bool saving;
  final VoidCallback? onPressed;

  const _FinishButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final completeT = t.onboarding.complete;
    if (!saving) {
      return OnboardingPrimaryButton(
        label: completeT.finish,
        onPressed: onPressed,
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: AppSpacing.xxl,
      ),
      child: ElevatedButton(
        onPressed: null,
        child: Semantics(
          label: completeT.saving,
          child: const SizedBox.square(
            dimension: AppSpacing.md,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
