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
          SettingsSectionHeader(title: localTitle),
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

/// A [SettingsSection] header on its own, for lists that build their rows
/// lazily with [SettingsSectionSlot].
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Semantics(
        header: true,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// One row's slice of a [SettingsSection] card, so a long section can be
/// built lazily in a `ListView.builder` and still look like one card: only
/// the first and last rows round their corners, and every row after the
/// first starts with the section divider.
class SettingsSectionSlot extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget child;

  const SettingsSectionSlot({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const radius = Radius.circular(AppSpacing.radiusCard);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? radius : Radius.zero,
          bottom: isLast ? radius : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFirst)
              Divider(height: 1, thickness: 1, color: palette.divider),
            child,
          ],
        ),
      ),
    );
  }
}
