import 'package:flutter/material.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localSubtitle = subtitle;
    final hasSubtitle = localSubtitle != null;
    final localActions = actions;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (localSubtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      localSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurface.withAlpha(140),
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: hasSubtitle ? 22 : 24,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (localActions != null)
            Row(mainAxisSize: MainAxisSize.min, children: localActions),
        ],
      ),
    );
  }
}
