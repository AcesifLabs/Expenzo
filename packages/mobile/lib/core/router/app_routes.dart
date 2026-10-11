import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/all_categories_picker_page.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_screen.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/auto_import_page.dart';
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
    GoRoute(
      path: 'settings',
      builder: (_, _) => const SettingsPage(),
      routes: [
        GoRoute(path: 'auto-import', builder: (_, _) => const AutoImportPage()),
        GoRoute(
          path: 'matching-rules',
          builder: (_, _) => BlocProvider(
            create: (_) => di.getIt<ParsingRulesBloc>()..add(LoadRules()),
            child: const RulesListPage(),
          ),
        ),
        GoRoute(
          path: 'recurring',
          // create:, not a bloc built in the builder: go_router rebuilds
          // this route when pages are pushed on top of it.
          builder: (_, _) => BlocProvider(
            create: (_) => di.getIt<RecurringBloc>(),
            child: const RecurringListView(),
          ),
        ),
      ],
    ),
    ..._buildBudgetRoutes(),
    ..._buildRecurringRoutes(),
    ..._buildCategoryRoutes(),
    GoRoute(path: 'scan-results', builder: _buildScanResultsRoute),
    GoRoute(path: 'login', builder: (_, _) => const LoginPage()),
    GoRoute(path: 'sync-conflict', builder: (_, _) => const SyncConflictPage()),
    GoRoute(path: 'reports', builder: (_, _) => const ReportsScreen()),
    GoRoute(path: 'ai-assistant', builder: (_, _) => const AiAssistantPage()),
  ];
}

List<RouteBase> _buildBudgetRoutes() {
  return [
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
        child: const RecurringFormPage(),
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
String? authRedirect(BuildContext context, GoRouterState state) =>
    authRedirectFor(context.read<AuthBloc>().state, state.matchedLocation);

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

  return null;
}
