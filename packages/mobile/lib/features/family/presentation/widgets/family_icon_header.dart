import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The round icon, heading and body text at the top of the Create, Join and
/// Invite screens.
class FamilyIconHeader extends StatelessWidget {
  final IconData icon;
  final String heading;
  final String body;

  const FamilyIconHeader({
    super.key,
    required this.icon,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        CircleAvatar(
          radius: AppSpacing.xl,
          backgroundColor: palette.accentFill,
          child: Icon(icon, color: palette.onAccentFill, size: AppSpacing.xl),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          heading,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          style: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
