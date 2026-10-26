import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_page_frame.dart';

class TutorialCta extends StatelessWidget {
  final VoidCallback onStart;

  const TutorialCta({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final ctaT = t.onboarding.tutorial.cta;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: AppSpacing.xl),
                Icon(
                  PiconsRegular.checkCircle,
                  size: AppSpacing.xxl,
                  color: context.palette.accent,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ctaT.title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ctaT.body,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OnboardingPrimaryButton(label: ctaT.start, onPressed: onStart),
        ],
      ),
    );
  }
}
