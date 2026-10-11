import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

/// A section header plus one grouped card of rows.
///
/// Store [title] in sentence case; this widget upper-cases it. A null
/// [title] gives a card with no header (the Sign out row). A section with
/// no visible rows renders nothing. Hide a row with collection-if in
/// `children`; never add a placeholder row.
class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final palette = context.palette;
    final localTitle = title;
    final divider = Divider(height: 1, thickness: 1, color: palette.divider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (localTitle == null)
          const SizedBox(height: AppSpacing.lg)
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Semantics(
              header: true,
              child: Text(
                localTitle.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: palette.textSecondary),
              ),
            ),
          ),
        AppCard(
          backgroundColor: palette.surface,
          borderRadius: AppSpacing.radiusCard,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0) divider,
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
