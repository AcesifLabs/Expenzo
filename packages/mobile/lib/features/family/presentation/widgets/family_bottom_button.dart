import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class FamilyBottomButton extends StatelessWidget {
  final String label;
  final bool busy;

  final VoidCallback? onPressed;

  const FamilyBottomButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.sm,
        AppSpacing.pageGutter,
        AppSpacing.md,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: AppSpacing.xxl,
        ),
        child: ElevatedButton(
          onPressed: busy ? null : onPressed,
          child: busy
              ? const SizedBox.square(
                  dimension: AppSpacing.md,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      ),
    );
  }
}
