import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The full-width primary button under a Family form, like the goal form's.
/// Shows a spinner and ignores taps while [busy].
class FamilyBottomButton extends StatelessWidget {
  final String label;
  final bool busy;

  /// Null disables the button.
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
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.xxl,
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
