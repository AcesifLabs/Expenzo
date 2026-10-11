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
    return AlertDialog(
      title: Text(t.settings.deleteDialog.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.settings.deleteDialog.question),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.settings.deleteDialog.listTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(t.settings.deleteDialog.expenses),
          Text(t.settings.deleteDialog.categories),
          Text(t.settings.deleteDialog.budgets),
          Text(t.settings.deleteDialog.recurring),
          Text(t.settings.deleteDialog.rules),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.settings.deleteDialog.cannotUndo,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Checkbox(value: _confirmed, onChanged: _onCheckboxChanged),
              Expanded(child: Text(t.settings.deleteDialog.confirm)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: _onCancel, child: Text(t.common.cancel)),
        TextButton(
          onPressed: _confirmed ? _onDelete : null,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(t.common.delete),
        ),
      ],
    );
  }
}
