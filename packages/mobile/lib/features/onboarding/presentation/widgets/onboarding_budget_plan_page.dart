import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/budgets/domain/budget_plan.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/budget_plan_editor.dart';
import 'package:expense_tracker/features/budgets/presentation/widgets/plan_donut.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/onboarding_plan.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import 'onboarding_page_frame.dart';

class OnboardingBudgetPlanPage extends StatefulWidget {
  const OnboardingBudgetPlanPage({super.key});

  @override
  State<OnboardingBudgetPlanPage> createState() =>
      _OnboardingBudgetPlanPageState();
}

class _OnboardingBudgetPlanPageState extends State<OnboardingBudgetPlanPage>
    with AutomaticKeepAliveClientMixin {
  final _editor = GlobalKey<BudgetPlanEditorState>();
  List<PlanRow>? _rows;
  double? _seededBase;
  var _edited = false;

  @override
  bool get wantKeepAlive => true;

  /// Follows the suggestion while the user hasn't touched it, so income
  /// changed on an earlier step still shows up here, even after a
  /// Continue. Rows restored from the draft count as the user's own.
  List<PlanRow> _rowsFor(OnboardingDraft draft, double base) {
    final rows = _rows;
    if (rows == null) {
      final submitted = draft.budgetRows;
      _edited = submitted != null;
      _seededBase = base;

      return _rows = submitted ?? suggestedPlanRows(base);
    }
    if (_edited || _seededBase == base) return rows;
    _seededBase = base;

    return _rows = suggestedPlanRows(base);
  }

  void _onChanged(List<PlanRow> rows) => setState(() {
    _rows = rows;
    _edited = true;
  });

  void _onContinue(List<PlanRow> rows) {
    if (validatePlan(rows, allowZero: true).isNotEmpty) {
      _editor.currentState?.revealErrors();

      return;
    }
    context.read<OnboardingBloc>().add(BudgetPlanSubmitted(rows));
  }

  void _onSkip() =>
      context.read<OnboardingBloc>().add(const BudgetPlanSubmitted([]));

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final planT = t.onboarding.plan;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final draft = context.select<OnboardingBloc, OnboardingDraft>(
      (bloc) => bloc.state.draft,
    );
    final base = planBaseFor(draft);
    final rows = _rowsFor(draft, base);

    return OnboardingPageFrame(
      title: planT.title,
      subtitle: planT.subtitle,
      onContinue: () => _onContinue(rows),
      body: [
        Center(
          child: PlanDonut(rows: rows, base: base),
        ),
        if (base <= 0) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            draft.monthlyIncome == null ? planT.noIncome : planT.noRoom,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        BudgetPlanEditor(
          key: _editor,
          rows: rows,
          base: base,
          allowZero: true,
          onChanged: _onChanged,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
            onPressed: _onSkip,
            child: Text(
              planT.skip,
              style: textTheme.labelLarge?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
