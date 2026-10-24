import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// The layout every setup page shares: title, subtitle, a scrolling body and
/// a Continue button kept above the keyboard. [onContinue] null disables it.
class OnboardingPageFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> body;
  final VoidCallback? onContinue;

  const OnboardingPageFrame({
    super.key,
    required this.title,
    this.subtitle,
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

/// [OnboardingPageFrame] with any [bottom] widget (the last page puts Finish
/// setup there).
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

/// Full-width themed primary button.
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
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.xxl,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
