import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class OnboardingStepDots extends StatelessWidget {
  static const _dot = 8.0;
  static const _line = Size(24, 2);

  final int current;
  final int total;

  const OnboardingStepDots({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final upcoming = palette.textSecondary.withValues(alpha: 0.25);
    Color dotColor(int i) {
      if (i < current) return palette.accent;

      return i == current ? palette.brand : upcoming;
    }

    return Semantics(
      label: t.onboarding.common.stepOf(current: current + 1, total: total),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0)
                Container(
                  width: _line.width,
                  height: _line.height,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  color: i <= current ? palette.accent : upcoming,
                ),
              Container(
                width: _dot,
                height: _dot,
                decoration: BoxDecoration(
                  color: dotColor(i),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
