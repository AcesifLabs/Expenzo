import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/budgets/domain/budget_plan.dart';
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
  static String? _subtitle(OnboardingDraft draft, GoalDraft goal) {
    if (planBaseFor(draft) <= 0) return null;
    final perMonth = _savings(draft);
    final timelineT = t.onboarding.timeline;
    final fastest = fastestAffordableMonths(
      timelineOptions(target: goal.targetAmount, savingsPerMonth: perMonth),
    );
    final savings = CurrencyFormatter.format(perMonth);

    return fastest == null
        ? timelineT.cannotAfford(amount: savings)
        : timelineT.canAfford(
            name: goal.name,
            months: fastest,
            amount: savings,
          );
  }

  static double _savings(OnboardingDraft draft) =>
      planSavings(planBaseFor(draft), planRowsFor(draft));

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

  List<Widget> _options(
    BuildContext context,
    OnboardingDraft draft,
    GoalDraft goal,
  ) {
    final savings = _savings(draft);
    final hasBase = planBaseFor(draft) > 0;
    final options = timelineOptions(
      target: goal.targetAmount,
      savingsPerMonth: savings,
    );
    final custom = goal.customDate;
    final customOption = custom == null
        ? null
        : customTimeline(
            target: goal.targetAmount,
            from: clock.now(),
            date: custom,
            savingsPerMonth: savings,
          );
    final bloc = context.read<OnboardingBloc>();
    final timelineT = t.onboarding.timeline;

    return [
      for (final option in options) ...[
        _TimelineCard(
          title: timelineT.months(n: option.months),
          option: option,
          showMark: hasBase,
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
        showMark: hasBase,
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
      subtitle: goal == null ? null : _subtitle(draft, goal),
      body: [
        if (goal != null) ..._options(context, draft, goal),
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
  static Widget _mark(AppPalette palette, TimelineFit fit) {
    final fitT = t.onboarding.timeline.fit;
    final (icon, color, label) = switch (fit) {
      TimelineFit.affordable => (
        PiconsRegular.checkCircle,
        palette.brand,
        fitT.affordable,
      ),
      TimelineFit.tooExpensive => (
        PiconsRegular.xCircle,
        palette.expense,
        fitT.tooExpensive,
      ),
      TimelineFit.slow => (PiconsRegular.warning, palette.warning, fitT.slow),
    };

    return Icon(icon, color: color, semanticLabel: label);
  }

  final String title;
  final String? subtitle;
  final TimelineOption? option;
  final bool showMark;
  final bool selected;
  final VoidCallback onTap;

  const _TimelineCard({
    required this.title,
    this.subtitle,
    required this.option,
    required this.showMark,
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
        child: Row(
          children: [
            Expanded(
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
            if (option != null && showMark) _mark(palette, option.fit),
          ],
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
