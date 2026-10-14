import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

/// The header every screen uses (DESIGN.md, Components): an optional back or
/// close button, a 24pt title with an optional subtitle under it, and
/// actions on the right.
///
/// Works in a page body or as a `Scaffold.appBar` (it handles the status bar
/// itself).
class AppPageHeader extends StatelessWidget implements PreferredSizeWidget {
  // As a `Scaffold.appBar` the header gets exactly [preferredSize], which
  // can't follow the text size, so its own text stops growing where it still
  // fits: a 30 px title line (+ a 20.3 px subtitle line) inside 24 px of
  // padding. Body text elsewhere keeps the full Font size scale (SAAP-66).
  static const _maxTitleScale = 1.6;
  static const _maxTitleAndSubtitleScale = 1.35;

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  /// Usually an `AppBackButton`.
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
          // The back button carries its own 48dp touch area, so the row starts
          // closer to the edge to keep the caret on the 24dp gutter visually.
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
