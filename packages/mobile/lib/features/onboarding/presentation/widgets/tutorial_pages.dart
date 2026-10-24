import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'onboarding_page_frame.dart';
import 'onboarding_step_dots.dart';
import 'tutorial_cta.dart';

/// One tutorial page: a real-app screenshot for each theme (Q25, captured
/// signed out, English) and its text.
class TutorialPageData {
  final String lightAsset;
  final String darkAsset;
  final String Function() title;
  final String Function() body;

  const TutorialPageData({
    required this.lightAsset,
    required this.darkAsset,
    required this.title,
    required this.body,
  });
}

String _dashboardTitle() => t.onboarding.tutorial.dashboard.title;
String _dashboardBody() => t.onboarding.tutorial.dashboard.body;
String _addTitle() => t.onboarding.tutorial.addTransaction.title;
String _addBody() => t.onboarding.tutorial.addTransaction.body;
String _reportsTitle() => t.onboarding.tutorial.reports.title;
String _reportsBody() => t.onboarding.tutorial.reports.body;

/// The three screenshot pages, in order.
@visibleForTesting
const tutorialPages = [
  TutorialPageData(
    lightAsset: 'assets/images/onboarding/tutorial_dashboard_light.png',
    darkAsset: 'assets/images/onboarding/tutorial_dashboard_dark.png',
    title: _dashboardTitle,
    body: _dashboardBody,
  ),
  TutorialPageData(
    lightAsset: 'assets/images/onboarding/tutorial_add_transaction_light.png',
    darkAsset: 'assets/images/onboarding/tutorial_add_transaction_dark.png',
    title: _addTitle,
    body: _addBody,
  ),
  TutorialPageData(
    lightAsset: 'assets/images/onboarding/tutorial_reports_light.png',
    darkAsset: 'assets/images/onboarding/tutorial_reports_dark.png',
    title: _reportsTitle,
    body: _reportsBody,
  ),
];

/// Three swipeable screenshot pages and the CTA (replaces the design's intro
/// video). Used at the end of onboarding and from Help → Watch tutorial.
class TutorialPages extends StatefulWidget {
  final VoidCallback onDone;

  const TutorialPages({super.key, required this.onDone});

  @override
  State<TutorialPages> createState() => _TutorialPagesState();
}

class _TutorialPagesState extends State<TutorialPages> {
  final _controller = PageController();
  var _page = 0;

  void _onPageChanged(int page) => setState(() => _page = page);

  void _next() => _controller.nextPage(
    duration: AppSpacing.durationNormal,
    curve: Curves.easeOut,
  );

  Widget _controls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        0,
        AppSpacing.pageGutter,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppSpacing.minTapTarget),
            ),
            onPressed: widget.onDone,
            child: Text(
              t.onboarding.common.skip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: OnboardingPrimaryButton(
              label: t.common.next,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = tutorialPages.length + 1;
    final onCta = _page == tutorialPages.length;

    return ColoredBox(
      color: context.palette.bg,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: t.onboarding.tutorial.pageOf(
              current: _page + 1,
              total: total,
            ),
            child: ExcludeSemantics(
              child: OnboardingStepDots(current: _page, total: total),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: _onPageChanged,
              children: [
                for (final page in tutorialPages) _TutorialPage(page: page),
                TutorialCta(onStart: widget.onDone),
              ],
            ),
          ),
          if (!onCta) _controls(context),
        ],
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final TutorialPageData page;

  const _TutorialPage({required this.page});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final title = page.title();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pageGutter),
      child: Column(
        children: [
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Image.asset(
                dark ? page.darkAsset : page.lightAsset,
                semanticLabel: title,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            page.body(),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
