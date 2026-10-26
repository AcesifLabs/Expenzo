import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/lifecycle/local_data_epoch.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_shell.dart';

class AuthAwareAppShell extends StatelessWidget {
  const AuthAwareAppShell({super.key});

  Widget _buildShell(BuildContext _, int epoch, Widget? _) =>
      AppShell(key: ValueKey(epoch));

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return switch (authState) {
      AuthSyncConflictPending() => const SyncConflictPage(),
      _ => ValueListenableBuilder<int>(
        valueListenable: di.getIt<LocalDataEpoch>(),
        builder: _buildShell,
      ),
    };
  }
}
