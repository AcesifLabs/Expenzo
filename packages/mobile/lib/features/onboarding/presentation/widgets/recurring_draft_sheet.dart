import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/default_frequency.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../domain/entities/onboarding_draft.dart';

Future<RecurringDraft?> showRecurringDraftSheet(BuildContext context) {
  final settings = switch (_settingsBloc(context)?.state) {
    SettingsLoaded(:final settings) => settings,
    SettingsUpdateSuccess(:final settings) => settings,
    _ => null,
  };

  return showModalBottomSheet<RecurringDraft>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _RecurringDraftSheet(
      initialFrequency: defaultFrequencyFrom(
        settings?.defaultRecurringFrequency,
      ),
    ),
  );
}

SettingsBloc? _settingsBloc(BuildContext context) {
  try {
    return context.read<SettingsBloc>();
  } on ProviderNotFoundException {
    return di.getIt.isRegistered<SettingsBloc>()
        ? di.getIt<SettingsBloc>()
        : null;
  }
}

class _RecurringDraftSheet extends StatefulWidget {
  final RecurringFrequency initialFrequency;

  @override
  State<_RecurringDraftSheet> createState() => _RecurringDraftSheetState();

  const _RecurringDraftSheet({required this.initialFrequency});
}

class _RecurringDraftSheetState extends State<_RecurringDraftSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  RecurringFrequency? _frequency;

  @override
  void initState() {
    super.initState();
    _frequency = widget.initialFrequency;
  }

  String? _validateName(String? value) =>
      (value ?? '').trim().isEmpty ? t.recurring.form.nameRequired : null;

  String? _validateAmount(String? value) {
    final formT = t.recurring.form;
    final text = (value ?? '').trim();
    if (text.isEmpty) return formT.amountRequired;
    final amount = parseAmountInput(text);

    return amount == null || amount <= 0 ? formT.amountInvalid : null;
  }

  void _onFrequency(RecurringFrequency? value) =>
      setState(() => _frequency = value);

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      RecurringDraft(
        description: _name.text.trim(),
        amount: parseAmountInput(_amount.text) ?? 0,
        frequency: _frequency ?? RecurringFrequency.monthly,
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetT = t.onboarding.recurring.sheet;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                sheetT.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: sheetT.name,
                  hintText: sheetT.nameHint,
                ),
                validator: _validateName,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: sheetT.amount),
                validator: _validateAmount,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(labelText: sheetT.frequency),
                items: [
                  for (final f in RecurringFrequency.values)
                    DropdownMenuItem(value: f, child: Text(f.displayName)),
                ],
                onChanged: _onFrequency,
              ),
              const SizedBox(height: AppSpacing.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.xxl),
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(t.common.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
