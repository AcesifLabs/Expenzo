import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';

import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_budget_plan_page.dart';
import '../widgets/onboarding_goal_page.dart';
import '../widgets/onboarding_income_page.dart';
import '../widgets/onboarding_recurring_page.dart';
import '../widgets/onboarding_step_dots.dart';
import '../widgets/onboarding_timeline_page.dart';
import '../widgets/tutorial_pages.dart';

class OnboardingRoute extends StatefulWidget {
  const OnboardingRoute({super.key});

  @override
  State<OnboardingRoute> createState() => _OnboardingRouteState();
}

class _OnboardingRouteState extends State<OnboardingRoute> {
  Future<void>? _ready;

  @override
  void initState() {
    super.initState();
    _ready = di.featureDependenciesReady;
  }

  void _retry() => setState(() => _ready = di.featureDependenciesReady);

  Widget _build(BuildContext context, AsyncSnapshot<void> snapshot) {
    final Widget body;
    if (snapshot.hasError) {
      body = AppEmptyState(
        icon: PiconsRegular.warningCircle,
        message: t.common.errors.storage,
        actionLabel: t.common.tryAgain,
        onAction: _retry,
      );
    } else if (snapshot.connectionState != ConnectionState.done) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      return BlocProvider(
        create: (_) =>
            di.getIt<OnboardingBloc>()..add(const OnboardingStarted()),
        child: const OnboardingPage(),
      );
    }

    return Scaffold(backgroundColor: context.palette.bg, body: body);
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<void>(future: _ready, builder: _build);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();

  void _onStateChanged(BuildContext context, OnboardingState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == OnboardingStatus.failure) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(state.errorText ?? '')));

      return;
    }
    if (state.status == OnboardingStatus.done) {
      if (state.result?.hadErrors ?? false) {
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(t.onboarding.complete.partialFailure)),
          );
      }

      di.getIt<SettingsBloc>().add(const LoadSettings());

      return;
    }
    if (_pages.hasClients && _pages.page?.round() != state.step) {
      _pages.animateToPage(
        state.step,
        duration: AppSpacing.durationNormal,
        curve: Curves.easeOut,
      );
    }
  }

  void _goHome() => context.go(AppRootTab.home.location);

  void _back() =>
      context.read<OnboardingBloc>().add(const OnboardingStepBack());

  void _skip() => context.read<OnboardingBloc>().add(const OnboardingSkipped());

  void _onPop(bool didPop) {
    if (didPop) return;
    if (context.read<OnboardingBloc>().state.canGoBack) _back();
  }

  Widget _header(BuildContext context, OnboardingState state) {
    final palette = context.palette;
    final common = t.onboarding.common;

    return Column(
      children: [
        SizedBox(
          height: AppSpacing.minTapTarget,
          child: Row(
            children: [
              if (state.canGoBack)
                IconButton(
                  icon: Icon(
                    PiconsRegular.caretLeft,
                    color: palette.textPrimary,
                  ),
                  tooltip: t.common.back,
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTapTarget,
                    minHeight: AppSpacing.minTapTarget,
                  ),
                  onPressed: _back,
                ),
              const Spacer(),
            ],
          ),
        ),
        OnboardingStepDots(
          current: state.step,
          total: OnboardingState.stepCount,
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, AppSpacing.minTapTarget),
          ),
          onPressed: state.status == OnboardingStatus.saving ? null : _skip,
          child: Text(
            common.skip,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onPop(didPop),
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (a, b) => a.step != b.step || a.status != b.status,
        listener: _onStateChanged,
        child: Scaffold(
          backgroundColor: context.palette.bg,
          body: SafeArea(
            child: BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) => state.status == OnboardingStatus.done
                  ? TutorialPages(onDone: _goHome)
                  : Column(
                      children: [
                        _header(context, state),
                        Expanded(
                          child: PageView(
                            controller: _pages,
                            physics: const NeverScrollableScrollPhysics(),
                            children: const [
                              OnboardingIncomePage(),
                              OnboardingRecurringPage(),
                              OnboardingBudgetPlanPage(),
                              OnboardingGoalPage(),
                              OnboardingTimelinePage(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
