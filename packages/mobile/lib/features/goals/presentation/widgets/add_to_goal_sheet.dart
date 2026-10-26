import 'package:flutter/material.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

Future<double?> showAddToGoalSheet(
  BuildContext context, {
  required String goalName,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddToGoalSheet(goalName: goalName),
  );
}

class _AddToGoalSheet extends StatefulWidget {
  final String goalName;

  @override
  State<_AddToGoalSheet> createState() => _AddToGoalSheetState();

  const _AddToGoalSheet({required this.goalName});
}

class _AddToGoalSheetState extends State<_AddToGoalSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();

  String? _validate(String? value) {
    final errors = t.goals.errors;
    final text = (value ?? '').trim();
    if (text.isEmpty) return errors.amountPositive;
    final amount = parseAmountInput(text);
    if (amount == null || amount > AppConstants.maxAmount) {
      return errors.amountTooLarge;
    }

    return amount <= 0 ? errors.amountPositive : null;
  }

  void _save() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(parseAmountInput(_amount.text));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sheetT = t.goals.addSheet;
    final textTheme = Theme.of(context).textTheme;

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
                sheetT.title(name: widget.goalName),
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amount,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: sheetT.amount),
                validator: _validate,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                sheetT.note,
                style: textTheme.bodySmall?.copyWith(
                  color: context.palette.textSecondary,
                ),
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
