import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/onboarding_plan.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import 'onboarding_page_frame.dart';

/// Step 3 (frame `OnboardingBudgetCalc`): the fixed 50/30/20 split of what
/// is left after recurring payments ("Drag to adjust" is cut, ADR 0011).
class OnboardingBudgetPlanPage extends StatefulWidget {
  const OnboardingBudgetPlanPage({super.key});

  @override
  State<OnboardingBudgetPlanPage> createState() =>
      _OnboardingBudgetPlanPageState();
}

class _OnboardingBudgetPlanPageState extends State<OnboardingBudgetPlanPage>
    with AutomaticKeepAliveClientMixin {
  var _createBudgets = true;

  @override
  bool get wantKeepAlive => true;

  void _onSwitch(bool value) => setState(() => _createBudgets = value);

  List<Widget> _shareRows(BuildContext context, BudgetSplit split) {
    final palette = context.palette;
    final names = t.onboarding.budgetNames;
    final rows = [
      (names.needs, AppConstants.needsShare, split.needs, palette.accent),
      (names.wants, AppConstants.wantsShare, split.wants, palette.brand),
      (names.savings, AppConstants.savingsShare, split.savings, palette.info),
    ];

    return [
      for (final (name, share, amount, color) in rows)
        _ShareRow(name: name, share: share, amount: amount, color: color),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final planT = t.onboarding.plan;
    final draft = context.select<OnboardingBloc, OnboardingDraft>(
      (bloc) => bloc.state.draft,
    );
    final split = budgetSplitFor(
      monthlyIncome: draft.monthlyIncome,
      recurringTotal: recurringMonthlyTotal(draft.recurring),
    );
    final create = _createBudgets && !split.isEmpty;

    return OnboardingPageFrame(
      title: planT.title,
      subtitle: planT.subtitle,
      onContinue: () =>
          context.read<OnboardingBloc>().add(BudgetPlanSubmitted(create)),
      body: [
        Center(child: _PlanDonut(split: split)),
        if (split.isEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            draft.monthlyIncome == null ? planT.noIncome : planT.noRoom,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        ..._shareRows(context, split),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(planT.createBudgets),
          value: create,
          onChanged: split.isEmpty ? null : _onSwitch,
        ),
      ],
    );
  }
}

class _ShareRow extends StatelessWidget {
  final String name;
  final double share;
  final double amount;
  final Color color;

  const _ShareRow({
    required this.name,
    required this.share,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = t.onboarding.plan.share(percent: (share * 100).round());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: textTheme.bodyLarge)),
              Text(
                '$percent · ${CurrencyFormatter.format(amount)}',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            child: LinearProgressIndicator(
              value: share,
              color: color,
              backgroundColor: context.palette.progressTrack,
            ),
          ),
        ],
      ),
    );
  }
}

/// The donut with the monthly amount in the middle; one empty ring when
/// there is nothing to split.
class _PlanDonut extends StatelessWidget {
  static const _size = 180.0;

  static PieChartSectionData _section(double value, Color color) =>
      PieChartSectionData(value: value, color: color, radius: 28, title: '');

  final BudgetSplit split;

  const _PlanDonut({required this.split});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final planT = t.onboarding.plan;
    final sections = split.isEmpty
        ? [_section(1, palette.progressTrack)]
        : [
            _section(split.needs, palette.accent),
            _section(split.wants, palette.brand),
            _section(split.savings, palette.info),
          ];

    return Semantics(
      label: planT.chartLabel(
        needs: CurrencyFormatter.format(split.needs),
        wants: CurrencyFormatter.format(split.wants),
        savings: CurrencyFormatter.format(split.savings),
      ),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: split.isEmpty ? 0 : 2,
                  sections: sections,
                ),
              ),
              Text(
                planT.perMonth(amount: CurrencyFormatter.format(split.base)),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
