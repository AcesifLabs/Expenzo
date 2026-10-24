import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import 'onboarding_page_frame.dart';

/// Step 4 (frame `OnboardingAddGoal`): a goal name and a target typed by
/// hand (the price lookup is cut, ADR 0011). A goal is optional.
class OnboardingGoalPage extends StatefulWidget {
  const OnboardingGoalPage({super.key});

  @override
  State<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

class _OnboardingGoalPageState extends State<OnboardingGoalPage>
    with AutomaticKeepAliveClientMixin {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  var _goalName = '';
  double? _target;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final goal = context.read<OnboardingBloc>().state.draft.goal;
    if (goal != null) {
      _name.text = goal.name;
      _amount.text = CurrencyFormatter.formatInput(goal.targetAmount);
      _readInputs();
    }
  }

  void _readInputs() {
    _goalName = _name.text.trim();
    _target = parseAmountInput(_amount.text);
  }

  void _onChanged(String _) => setState(_readInputs);

  void _submit() {
    final amount = _target;
    if (_goalName.isEmpty || amount == null || amount <= 0) return;
    context.read<OnboardingBloc>().add(GoalSubmitted(_goalName, amount));
  }

  void _decline() => context.read<OnboardingBloc>().add(const GoalDeclined());

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final goalT = t.onboarding.goal;
    final amount = _target;
    final invalid = _amount.text.trim().isNotEmpty && amount == null;
    final valid = _goalName.isNotEmpty && amount != null && amount > 0;

    return OnboardingPageFrame(
      title: goalT.title,
      subtitle: goalT.subtitle,
      onContinue: valid ? _submit : null,
      body: [
        TextField(
          controller: _name,
          onChanged: _onChanged,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: goalT.nameLabel,
            hintText: goalT.nameHint,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _amount,
          onChanged: _onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: goalT.amountLabel,
            prefixText: '${CurrencyFormatter.current.value.symbol} ',
            errorText: invalid ? t.goals.errors.amountTooLarge : null,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
            onPressed: _decline,
            child: Text(
              goalT.notNow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
