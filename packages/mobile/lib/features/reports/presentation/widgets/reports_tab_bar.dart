import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class ReportsTabBar extends StatelessWidget {
  static const _tabs = ['Trend', 'Categories', 'Insights'];
  static const _activeWidths = {
    'Trend': 40.0,
    'Categories': 60.0,
    'Insights': 50.0,
  };

  static String _label(String tab) => switch (tab) {
    'Trend' => t.shell.reportsTabs.trend,
    'Categories' => t.shell.reportsTabs.categories,
    _ => t.shell.reportsTabs.insights,
  };

  final TabController controller;
  final ValueChanged<String> onTabChanged;

  const ReportsTabBar({
    super.key,
    required this.controller,
    required this.onTabChanged,
  });

  Color _labelColor(AppPalette palette, double selectedness) {
    return Color.lerp(palette.textSecondary, palette.brand, selectedness) ??
        palette.textSecondary;
  }

  FontWeight _fontWeight(double selectedness) {
    return FontWeight.lerp(FontWeight.normal, FontWeight.w600, selectedness) ??
        FontWeight.normal;
  }

  double _animationValue() {
    return controller.animation?.value ?? controller.index.toDouble();
  }

  double _underlineWidth(double value) {
    final leftIndex = value.floor().clamp(0, _tabs.length - 1);
    final rightIndex = value.ceil().clamp(0, _tabs.length - 1);
    final progress = value - leftIndex;
    final leftWidth = _activeWidths[_tabs[leftIndex]] ?? 40;
    final rightWidth = _activeWidths[_tabs[rightIndex]] ?? 40;

    return lerpDouble(leftWidth, rightWidth, progress) ?? leftWidth;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return SizedBox(
      height: AppSpacing.minTapTarget,
      child: AnimatedBuilder(
        animation: controller.animation ?? controller,
        builder: (context, _) {
          final value = _animationValue();

          return LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / _tabs.length;
              final underlineWidth = _underlineWidth(value);
              final underlineLeft =
                  ((value + 0.5) * tabWidth) - (underlineWidth / 2);

              return Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _tabs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tab = entry.value;
                      final selectedness = (1 - (value - index).abs()).clamp(
                        0.0,
                        1.0,
                      );

                      return Expanded(
                        child: Semantics(
                          button: true,
                          selected: index == value.round(),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTabChanged(tab),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _label(tab),
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: _labelColor(palette, selectedness),
                                    fontWeight: _fontWeight(selectedness),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Positioned(
                    left: underlineLeft,
                    bottom: 0,
                    child: Container(
                      width: underlineWidth,
                      height: 3,
                      decoration: BoxDecoration(
                        color: palette.brand,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
