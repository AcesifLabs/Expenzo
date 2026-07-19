import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/all_categories_picker_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_form_page.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_screen.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';
import 'package:expense_tracker/shared/presentation/pages/feedback_page.dart';

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
    GoRoute(path: 'settings', builder: (_, _) => const SettingsPage()),
    GoRoute(path: 'feedback', builder: (_, _) => const FeedbackPage()),
    GoRoute(path: 'records/new', builder: _buildNewRecordRoute),
    GoRoute(path: 'records/:id/edit', builder: _buildEditRecordRoute),
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
  ];
}

List<RouteBase> _buildCategoryRoutes() {
  return [
    GoRoute(
      path: 'categories/new',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final type = extra?['initialType'] as RecordType?;

        return BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: CategoryFormPage(initialType: type),
        );
      },
    ),
    GoRoute(
      path: 'categories/:id/edit',
      builder: (context, state) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: CategoryFormPage(categoryId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: 'categories/picker',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final type = extra?['type'] as RecordType? ?? RecordType.expense;
        final selectedId = extra?['selectedId'] as String?;

        return BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: AllCategoriesPickerPage(type: type, selectedId: selectedId),
        );
      },
    ),
  ];
}

Widget _buildNewRecordRoute(BuildContext _, GoRouterState state) {
  final extra = state.extra as Map<String, dynamic>?;
  final recordBloc = extra?['recordBloc'] as RecordBloc?;
  final categoryBloc = extra?['categoryBloc'] as CategoryBloc?;

  return MultiBlocProvider(
    providers: [
      if (recordBloc != null)
        BlocProvider.value(value: recordBloc)
      else
        BlocProvider(create: (_) => di.getIt<RecordBloc>()),
      if (categoryBloc != null)
        BlocProvider.value(value: categoryBloc)
      else
        BlocProvider(create: (_) => di.getIt<CategoryBloc>()),
    ],
    child: const RecordFormPage(),
  );
}

Widget _buildEditRecordRoute(BuildContext _, GoRouterState state) {
  final id = state.pathParameters['id'] ?? '';
  final extra = state.extra as Map<String, dynamic>?;
  final recordBloc = extra?['recordBloc'] as RecordBloc?;
  final categoryBloc = extra?['categoryBloc'] as CategoryBloc?;

  return MultiBlocProvider(
    providers: [
      if (recordBloc != null)
        BlocProvider.value(value: recordBloc)
      else
        BlocProvider(create: (_) => di.getIt<RecordBloc>()),
      if (categoryBloc != null)
        BlocProvider.value(value: categoryBloc)
      else
        BlocProvider(create: (_) => di.getIt<CategoryBloc>()),
    ],
    child: RecordFormPage(recordId: id),
  );
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

/// Redirects the user to /sync-conflict or back to / when they are
/// authenticated and try to reach /login. Returns null to let the
/// requested route resolve normally.
String? authRedirect(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;

  if (authState is AuthInitial || authState is AuthLoading) {
    return null;
  }

  final isAuth = authState is Authenticated;
  final isLoginRoute = state.matchedLocation == '/login';
  final isConflictRoute = state.matchedLocation == '/sync-conflict';

  if (authState is AuthSyncConflictPending && !isConflictRoute) {
    return '/sync-conflict';
  }

  if (isAuth && isLoginRoute) {
    return '/';
  }

  return null;
}
