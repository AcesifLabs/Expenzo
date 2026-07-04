import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_details_page.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_form_page.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';
import 'package:expense_tracker/shared/presentation/pages/feedback_page.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;

  // ignore: avoid-late-keyword, member-ordering
  late final GoRouter config = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _AppShellWithAuth(),
        routes: [
          GoRoute(path: 'settings', builder: (_, _) => const SettingsPage()),
          GoRoute(path: 'feedback', builder: (_, _) => const FeedbackPage()),
          GoRoute(
            path: 'records/new',
            builder: (context, state) {
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
            },
          ),
          GoRoute(
            path: 'records/:id/edit',
            builder: (context, state) {
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
            },
          ),
          GoRoute(
            path: 'budgets/new',
            builder: (context, state) => BlocProvider(
              create: (_) => di.getIt<BudgetBloc>(),
              child: const BudgetFormPage(),
            ),
          ),
          GoRoute(
            path: 'budgets/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';

              return BlocProvider(
                create: (_) => di.getIt<BudgetBloc>(),
                child: BudgetDetailsPage(budgetId: id),
              );
            },
          ),
          GoRoute(
            path: 'budgets/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';

              return BlocProvider(
                create: (_) => di.getIt<BudgetBloc>(),
                child: BudgetFormPage(budgetId: id),
              );
            },
          ),
          GoRoute(
            path: 'recurring/new',
            builder: (context, state) => BlocProvider(
              create: (_) => di.getIt<RecurringBloc>(),
              child: const RecurringFormPage(),
            ),
          ),
          GoRoute(
            path: 'recurring/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';

              return BlocProvider(
                create: (_) => di.getIt<RecurringBloc>(),
                child: RecurringFormPage(recurringId: id),
              );
            },
          ),
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
            path: 'scan-results',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final bloc = extra?['smsBloc'] as SmsScannerBloc?;
              if (bloc != null) {
                return BlocProvider.value(
                  value: bloc,
                  child: const SmsScanResultsPage(),
                );
              }

              return BlocProvider(
                create: (_) => di.getIt<SmsScannerBloc>(),
                child: const SmsScanResultsPage(),
              );
            },
          ),
          GoRoute(path: 'login', builder: (_, _) => const LoginPage()),
          GoRoute(
            path: 'sync-conflict',
            builder: (_, _) => const SyncConflictPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isAuth = authState is Authenticated;
      final isLoginRoute = location == '/login';
      final isConflictRoute = location == '/sync-conflict';

      if (authState is AuthSyncConflictPending && !isConflictRoute) {
        return '/sync-conflict';
      }

      if (isAuth && isLoginRoute) {
        return '/';
      }

      return null;
    },
  );

  AppRouter({required GlobalKey<NavigatorState> navigatorKey})
    : _navigatorKey = navigatorKey;
}

class _AppShellWithAuth extends StatelessWidget {
  const _AppShellWithAuth();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return switch (authState) {
      AuthSyncConflictPending() => const SyncConflictPage(),
      _ => const AppShell(),
    };
  }
}
