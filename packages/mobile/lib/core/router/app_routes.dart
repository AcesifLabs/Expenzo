import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/router/help_route.dart';
import 'package:expense_tracker/core/router/family_route.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_home_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_invite_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_join_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_members_page.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/all_budgets_picker_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/data_wipe/presentation/pages/delete_all_data_page.dart';
import 'package:expense_tracker/features/export/presentation/pages/export_data_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/all_categories_picker_page.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_frequency.dart';
import 'package:expense_tracker/features/recurring/domain/helpers/default_frequency.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_screen.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/appearance_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/calendar_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/currency_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/font_size_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/home_page_settings_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/language_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/number_format_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/profile_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_form_bloc.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_form_event.dart';
import 'package:expense_tracker/features/goals/presentation/pages/goal_form_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/tutorial_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/about_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/faq_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/help_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/rate_app_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/auto_import_page.dart';
import 'package:expense_tracker/features/sync/presentation/pages/sync_settings_page.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_list_page.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_bloc.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_event.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/pages/rules_list_page.dart';

import '../../features/auth/presentation/bloc/auth_state.dart';
import 'auth_aware_app_shell.dart';

/// Builds the full route tree for the app.
///
/// The auth-aware root layout is mounted at `/` so the redirect can
/// intercept login/sync-conflict states before any nested route renders.
List<RouteBase> buildAppRoutes() {
  return [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthAwareAppShell(),
      routes: _buildNestedRoutes(),
    ),
  ];
}

List<RouteBase> _buildNestedRoutes() {
  return [
    _buildSettingsRoute(),
    ..._buildBudgetRoutes(),
    ..._buildRecurringRoutes(),
    ..._buildCategoryRoutes(),
    GoRoute(path: 'scan-results', builder: _buildScanResultsRoute),
    GoRoute(path: 'login', builder: (_, _) => const LoginPage()),
    GoRoute(path: 'sync-conflict', builder: (_, _) => const SyncConflictPage()),
    GoRoute(path: 'reports', builder: (_, _) => const ReportsScreen()),
    GoRoute(path: 'ai-assistant', builder: (_, _) => const AiAssistantPage()),
    GoRoute(path: 'onboarding', builder: (_, _) => const OnboardingRoute()),
    GoRoute(path: 'tutorial', builder: (_, _) => const TutorialPage()),
    // Before 'goals/:id/edit' so "new" is never read as an id.
    GoRoute(
      path: 'goals/new',
      builder: (_, _) => BlocProvider(
        create: (_) =>
            di.getIt<GoalFormBloc>()..add(const GoalFormStartedNew()),
        child: const GoalFormPage(),
      ),
    ),
    GoRoute(
      path: 'goals/:id/edit',
      builder: (_, state) {
        final id = state.pathParameters['id'] ?? '';

        return BlocProvider(
          create: (_) => di.getIt<GoalFormBloc>()..add(GoalFormLoaded(id)),
          child: GoalFormPage(goalId: id),
        );
      },
    ),
  ];
}

/// Settings and every screen it opens, at `/settings/<SettingsRoute.path>`.
GoRoute _buildSettingsRoute() {
  return GoRoute(
    path: SettingsRoute.rootPath,
    builder: (_, _) => const SettingsPage(),
    routes: [
      _settingsPage(SettingsRoute.profile, const ProfilePage()),
      _settingsPage(SettingsRoute.appearance, const AppearancePage()),
      _settingsPage(SettingsRoute.currency, const CurrencyPage()),
      _settingsPage(SettingsRoute.language, const LanguagePage()),
      _settingsPage(SettingsRoute.numberFormat, const NumberFormatPage()),
      _settingsPage(SettingsRoute.fontSize, const FontSizePage()),
      _settingsPage(SettingsRoute.calendar, const CalendarPage()),
      _settingsPage(SettingsRoute.homePage, const HomePageSettingsPage()),
      _settingsPage(
        SettingsRoute.notifications,
        const NotificationSettingsPage(),
      ),
      _settingsPage(SettingsRoute.categories, const CategoryListPage()),
      _settingsPage(SettingsRoute.autoImport, const AutoImportPage()),
      GoRoute(
        path: SettingsRoute.matchingRules.path,
        builder: (_, _) => BlocProvider(
          create: (_) => di.getIt<ParsingRulesBloc>()..add(LoadRules()),
          child: const RulesListPage(),
        ),
      ),
      GoRoute(
        path: SettingsRoute.recurring.path,
        // create:, not a bloc built in the builder: go_router rebuilds
        // this route when pages are pushed on top of it.
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.getIt<RecurringBloc>()),
            // The app-wide singleton; `create` would close it on pop.
            BlocProvider.value(value: di.getIt<SettingsBloc>()),
          ],
          child: const RecurringListView(),
        ),
      ),
      _settingsPage(SettingsRoute.sync, const SyncSettingsPage()),
      _settingsPage(SettingsRoute.export, const ExportDataPage()),
      _settingsPage(SettingsRoute.deleteData, const DeleteAllDataPage()),
      _buildHelpRoute(),
      _buildFamilyRoute(),
    ],
  );
}

/// A settings screen with no bloc of its own.
GoRoute _settingsPage(SettingsRoute route, Widget page) =>
    GoRoute(path: route.path, builder: (_, _) => page);

/// Family group and its screens, at `/settings/family/<FamilyRoute.path>`.
/// Each page gets its own FamilyBloc with `create:` (a factory): child
/// pages are pushed as siblings, so a provider here would not reach them.
/// Every bloc starts from the per-account cache, so all show one group.
GoRoute _buildFamilyRoute() {
  Widget withBloc(Widget page) => BlocProvider(
    create: (_) => di.getIt<FamilyBloc>()..add(const FamilyLoadRequested()),
    child: page,
  );

  return GoRoute(
    path: SettingsRoute.family.path,
    builder: (_, _) => withBloc(const FamilyHomePage()),
    routes: [
      GoRoute(
        path: FamilyRoute.join.path,
        builder: (_, _) => withBloc(const FamilyJoinPage()),
      ),
      GoRoute(
        path: FamilyRoute.invite.path,
        builder: (_, _) => withBloc(const FamilyInvitePage()),
      ),
      GoRoute(
        path: FamilyRoute.members.path,
        builder: (_, _) => withBloc(const FamilyMembersPage()),
      ),
    ],
  );
}

/// Help & Support and its screens, at `/settings/help/<HelpRoute.path>`.
GoRoute _buildHelpRoute() {
  return GoRoute(
    path: SettingsRoute.help.path,
    builder: (_, _) => const HelpPage(),
    routes: [
      GoRoute(path: HelpRoute.faq.path, builder: (_, _) => const FaqPage()),
      GoRoute(
        path: HelpRoute.rate.path,
        builder: (_, _) => const RateAppPage(),
      ),
      GoRoute(path: HelpRoute.about.path, builder: (_, _) => const AboutPage()),
    ],
  );
}

List<RouteBase> _buildBudgetRoutes() {
  return [
    // Before 'budgets/:id', which would otherwise match "picker" as an id.
    GoRoute(
      path: 'budgets/picker',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final selectedId = extra?['selectedId'] as String?;

        return _dialogPage(state, AllBudgetsPickerPage(selectedId: selectedId));
      },
    ),
    GoRoute(
      path: 'budgets/new',
      builder: (_, _) => BlocProvider(
        create: (_) => di.getIt<BudgetBloc>(),
        child: const BudgetFormPage(),
      ),
    ),
    GoRoute(
      path: 'budgets/:id',
      builder: (context, state) => BlocProvider(
        create: (_) => di.getIt<BudgetBloc>()..add(const LoadBudgets()),
        child: BudgetDetailsPage(budgetId: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: 'budgets/:id/edit',
      builder: (context, state) => BlocProvider(
        create: (_) => di.getIt<BudgetBloc>(),
        child: BudgetFormPage(budgetId: state.pathParameters['id'] ?? ''),
      ),
    ),
  ];
}

List<RouteBase> _buildRecurringRoutes() {
  return [
    GoRoute(
      path: 'recurring/new',
      builder: (_, _) => BlocProvider(
        create: (_) => di.getIt<RecurringBloc>(),
        child: RecurringFormPage(defaultFrequency: _storedDefaultFrequency()),
      ),
    ),
    GoRoute(
      path: 'recurring/:id/edit',
      builder: (_, state) => BlocProvider(
        create: (_) => di.getIt<RecurringBloc>(),
        child: RecurringFormPage(recurringId: state.pathParameters['id']),
      ),
    ),
  ];
}

/// The Recurring screen's default frequency, including a change still
/// being saved; monthly until settings load.
RecurringFrequency _storedDefaultFrequency() {
  return defaultFrequencyFrom(
    di.getIt<SettingsBloc>().latestSettings?.defaultRecurringFrequency,
  );
}

/// Choosing or adding a category is a short task opened from a form, so it
/// opens as a full-screen dialog with a close button (see AppBackButton).
Page<Object?> _dialogPage(GoRouterState state, Widget child) {
  return MaterialPage<Object?>(
    key: state.pageKey,
    fullscreenDialog: true,
    child: child,
  );
}

List<RouteBase> _buildCategoryRoutes() {
  return [
    GoRoute(
      path: 'categories/new',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final type = extra?['initialType'] as RecordType?;

        return _dialogPage(
          state,
          BlocProvider.value(
            value: context.read<CategoryBloc>(),
            child: CategoryFormPage(initialType: type),
          ),
        );
      },
    ),
    GoRoute(
      path: 'categories/:id/edit',
      pageBuilder: (context, state) => _dialogPage(
        state,
        BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: CategoryFormPage(categoryId: state.pathParameters['id']),
        ),
      ),
    ),
    GoRoute(
      path: 'categories/picker',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final type = extra?['type'] as RecordType? ?? RecordType.expense;
        final selectedId = extra?['selectedId'] as String?;

        return _dialogPage(
          state,
          BlocProvider.value(
            value: context.read<CategoryBloc>(),
            child: AllCategoriesPickerPage(type: type, selectedId: selectedId),
          ),
        );
      },
    ),
  ];
}

Widget _buildScanResultsRoute(BuildContext _, GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  final bloc = extra?['smsBloc'] as SmsScannerBloc?;
  if (bloc != null) {
    return BlocProvider.value(value: bloc, child: const SmsScanResultsPage());
  }

  return BlocProvider(
    create: (_) => di.getIt<SmsScannerBloc>(),
    child: const SmsScanResultsPage(),
  );
}

/// Redirects the user to /sync-conflict while a sync conflict is pending and
/// back out of it once it is resolved. Returns null to let the requested
/// route resolve normally.
///
/// Leaving /login after signing in is LoginPage's job: it pops back to the
/// screen that opened it. Redirecting here too would race that pop.
///
/// Then sends a user who hasn't done onboarding to /onboarding (SAAP-74). A
/// pending sync conflict wins: onboarding waits until it is resolved, or the
/// two redirects would bounce between each other.
String? authRedirect(BuildContext context, GoRouterState state) => redirectFor(
  context.read<AuthBloc>().state,
  _loadedSettings(),
  state.matchedLocation,
);

@visibleForTesting
String? redirectFor(
  AuthState authState,
  UserSettings? settings,
  String location,
) {
  final authTarget = authRedirectFor(authState, location);
  if (authTarget != null || authState is AuthSyncConflictPending) {
    return authTarget;
  }

  return onboardingRedirectFor(settings, location);
}

/// The app-wide settings once loaded, else null (no redirect yet).
UserSettings? _loadedSettings() {
  if (!di.getIt.isRegistered<SettingsBloc>()) return null;

  return switch (di.getIt<SettingsBloc>().state) {
    SettingsLoaded(:final settings) => settings,
    SettingsUpdateSuccess(:final settings) => settings,
    _ => null,
  };
}

/// Onboarding opens by itself while [UserSettings.onboardingCompleted] is
/// false. A finished user may still open /onboarding (Replay setup).
@visibleForTesting
String? onboardingRedirectFor(UserSettings? settings, String location) {
  if (settings?.onboardingCompleted != false) return null;

  return location.startsWith('/onboarding') ? null : '/onboarding';
}

@visibleForTesting
String? authRedirectFor(AuthState authState, String location) {
  if (authState is AuthInitial || authState is AuthLoading) {
    return null;
  }

  final isConflictRoute = location == '/sync-conflict';
  final isConflictPending = authState is AuthSyncConflictPending;

  if (isConflictPending && !isConflictRoute) return '/sync-conflict';

  // The conflict page has no way out of its own (it blocks back), so leave
  // it as soon as the conflict is resolved.
  if (!isConflictPending && isConflictRoute) return '/';

  // Family group needs an account (ADR 0008).
  if (authState is Unauthenticated &&
      location.startsWith(SettingsRoute.family.location)) {
    return SettingsRoute.rootLocation;
  }

  return null;
}
