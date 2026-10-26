import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class ThemePreviewCard extends StatelessWidget {
  final Brightness brightness;

  const ThemePreviewCard({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final isDark = brightness == Brightness.dark;
    final screenT = t.settings.appearanceScreen;

    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Builder(
        builder: (context) {
          final palette = context.palette;
          final textTheme = Theme.of(context).textTheme;

          return Container(
            width: double.infinity,
            color: palette.surface,
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDark ? screenT.darkTitle : screenT.lightTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isDark ? screenT.darkBody : screenT.lightBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.smd),
                ExcludeSemantics(child: _Swatches(palette: palette)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  final AppPalette palette;

  const _Swatches({required this.palette});

  @override
  Widget build(BuildContext context) {
    final colors = [
      palette.accent,
      palette.surface,
      palette.bg,
      palette.brand,
      palette.expense,
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final color in colors)
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: palette.divider),
            ),
          ),
      ],
    );
  }
}
