import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class OnboardingPageFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> body;
  final VoidCallback? onContinue;

  const OnboardingPageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingPageLayout(
      title: title,
      subtitle: subtitle,
      body: body,
      bottom: OnboardingPrimaryButton(
        label: t.onboarding.common.continueLabel,
        onPressed: onContinue,
      ),
    );
  }
}

class OnboardingPageLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> body;
  final Widget bottom;

  const OnboardingPageLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = this.subtitle;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const SizedBox(height: AppSpacing.md),
              Text(title, style: textTheme.headlineMedium),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: context.palette.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              ...body,
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.sm,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: bottom,
        ),
      ],
    );
  }
}

class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: AppSpacing.xxl,
      ),
      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          textStyle: Theme.of(context).textTheme.titleMedium,
        ),
        child: Text(label),
      ),
    );
  }
}
