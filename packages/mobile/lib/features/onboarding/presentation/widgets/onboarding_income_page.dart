import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/income_frequency.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import 'onboarding_page_frame.dart';

class OnboardingIncomePage extends StatefulWidget {
  const OnboardingIncomePage({super.key});

  @override
  State<OnboardingIncomePage> createState() => _OnboardingIncomePageState();
}

class _OnboardingIncomePageState extends State<OnboardingIncomePage>
    with AutomaticKeepAliveClientMixin {
  static String _label(IncomeFrequency f) {
    final labels = t.onboarding.income.frequency;

    return switch (f) {
      IncomeFrequency.monthly => labels.monthly,
      IncomeFrequency.biWeekly => labels.biWeekly,
      IncomeFrequency.weekly => labels.weekly,
    };
  }

  final _amount = TextEditingController();
  var _frequency = IncomeFrequency.monthly;
  double? _parsed;

  @override
  void initState() {
    super.initState();

    final income = context.read<OnboardingBloc>().state.draft.monthlyIncome;
    if (income != null) _fill(income);
  }

  void _fill(double income) {
    _amount.text = CurrencyFormatter.formatInput(income);
    _parsed = parseAmountInput(_amount.text);
  }

  void _onStoredIncome(OnboardingState state) {
    final income = state.draft.monthlyIncome;
    if (income == null || _amount.text.isNotEmpty) return;
    setState(() => _fill(income));
  }

  @override
  bool get wantKeepAlive => true;

  void _onChanged(String text) =>
      setState(() => _parsed = parseAmountInput(text));

  void _onFrequency(Set<IncomeFrequency> selected) =>
      setState(() => _frequency = selected.first);

  void _submit() {
    final amount = _parsed;
    if (amount == null || amount <= 0) return;
    context.read<OnboardingBloc>().add(IncomeSubmitted(amount, _frequency));
  }

  Widget _summary(BuildContext context, double amount) {
    final palette = context.palette;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: palette.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Text(
        t.onboarding.income.perMonth(
          amount: CurrencyFormatter.format(_frequency.toMonthly(amount)),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: palette.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final incomeT = t.onboarding.income;
    final amount = _parsed;
    final invalid = _amount.text.trim().isNotEmpty && amount == null;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) =>
          previous.draft.monthlyIncome == null &&
          current.draft.monthlyIncome != null,
      listener: (_, state) => _onStoredIncome(state),
      child: OnboardingPageFrame(
        title: incomeT.title,
        subtitle: incomeT.subtitle,
        onContinue: amount != null && amount > 0 ? _submit : null,
        body: [
          TextField(
            controller: _amount,
            onChanged: _onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: incomeT.amountLabel,
              prefixText: '${CurrencyFormatter.current.value.symbol} ',
              errorText: invalid ? incomeT.amountInvalid : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            incomeT.frequencyLabel,
            style: textTheme.bodySmall?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<IncomeFrequency>(
            segments: [
              for (final f in IncomeFrequency.values)
                ButtonSegment(value: f, label: Text(_label(f))),
            ],
            selected: {_frequency},
            showSelectedIcon: false,
            onSelectionChanged: _onFrequency,
          ),
          if (amount != null && amount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            _summary(context, amount),
          ],
        ],
      ),
    );
  }
}
