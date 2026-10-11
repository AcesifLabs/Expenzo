import 'package:flutter/material.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;

  /// Defaults to "See all" in the app language.
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final onTrailingTap = this.onTrailingTap;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (onTrailingTap != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(trailingLabel ?? t.dashboard.sections.seeAll),
          ),
      ],
    );
  }
}
