import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you absolutely sure you want to delete your account?',
          ),
          const SizedBox(height: 16),
          const Text(
            'This will permanently delete:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• All your expenses'),
          const Text('• All your categories'),
          const Text('• All your budgets'),
          const Text('• All your recurring transactions'),
          const Text('• All your parsing rules'),
          const SizedBox(height: 16),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _confirmed,
                onChanged: (value) {
                  setState(() => _confirmed = value ?? false);
                },
              ),
              const Expanded(
                child: Text('I understand and want to delete my account'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _confirmed
              ? () {
                  Navigator.pop(context);
                  widget.onConfirm();
                }
              : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
