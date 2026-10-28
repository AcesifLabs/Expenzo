import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  static const _maxTitleScale = 1.6;
  static const _maxTitleAndSubtitleScale = 1.35;

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  final Widget? leading;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 72 : 96);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final localSubtitle = subtitle;
    final localActions = actions;
    final localLeading = leading;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: localSubtitle == null
          ? _maxTitleScale
          : _maxTitleAndSubtitleScale,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            localLeading == null ? AppSpacing.pageGutter : AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (localLeading != null) ...[
                localLeading,
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (localSubtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        localSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (localActions != null)
                Row(mainAxisSize: MainAxisSize.min, children: localActions),
            ],
          ),
        ),
      ),
    );
  }
}
