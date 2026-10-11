import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _confirmed = false;

  void _onCheckboxChanged(bool? value) {
    setState(() => _confirmed = value ?? false);
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onDelete() {
    Navigator.pop(context);
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final dialogT = t.settings.deleteDialog;
    final errorColor = Theme.of(context).colorScheme.error;

    return AlertDialog(
      title: Text(dialogT.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dialogT.question),
          const SizedBox(height: AppSpacing.md),
          Text(
            dialogT.listTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(dialogT.expenses),
          Text(dialogT.categories),
          Text(dialogT.budgets),
          Text(dialogT.recurring),
          Text(dialogT.rules),
          const SizedBox(height: AppSpacing.md),
          Text(dialogT.cannotUndo, style: TextStyle(color: errorColor)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Checkbox(value: _confirmed, onChanged: _onCheckboxChanged),
              Expanded(child: Text(dialogT.confirm)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: _onCancel, child: Text(t.common.cancel)),
        TextButton(
          onPressed: _confirmed ? _onDelete : null,
          style: TextButton.styleFrom(foregroundColor: errorColor),
          child: Text(t.common.delete),
        ),
      ],
    );
  }
}
