import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';

/// Root layout that observes the auth state and shows the
/// conflict-resolution screen when a sync conflict is pending,
/// otherwise the standard app shell.
class AuthAwareAppShell extends StatelessWidget {
  const AuthAwareAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return switch (authState) {
      AuthSyncConflictPending() => const SyncConflictPage(),
      _ => const AppShell(),
    };
  }
}
