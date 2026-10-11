import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

/// Calls [onAuthChanged] when a sync conflict starts or ends, so the router
/// redirect to and from /sync-conflict re-runs.
///
/// Only those changes refresh the router. Refreshing on every auth change
/// raced LoginPage popping itself after sign-in: the refresh finished later
/// and put /login back on screen.
///
/// The bloc is only read once [enabled] is true: [AuthBloc] is registered in
/// DI during app start-up, after the first frame, so reading it earlier
/// throws. The child is built the same way either way, so turning this on
/// doesn't rebuild the app below it.
class RefreshOnAuthChange extends StatefulWidget {
  final bool enabled;
  final VoidCallback onAuthChanged;
  final Widget child;

  const RefreshOnAuthChange({
    super.key,
    required this.enabled,
    required this.onAuthChanged,
    required this.child,
  });

  @override
  State<RefreshOnAuthChange> createState() => _RefreshOnAuthChangeState();
}

class _RefreshOnAuthChangeState extends State<RefreshOnAuthChange> {
  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeIfEnabled();
  }

  @override
  void didUpdateWidget(RefreshOnAuthChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscribeIfEnabled();
  }

  void _subscribeIfEnabled() {
    if (!widget.enabled || _subscription != null) return;
    final authBloc = context.read<AuthBloc>();
    var conflictPending = authBloc.state is AuthSyncConflictPending;
    _subscription = authBloc.stream.listen((state) {
      // Resolving a conflict passes through AuthLoading, where the redirect
      // deliberately waits. Only a settled state can end the conflict, or the
      // one refresh would land on the loading state and strand the user.
      if (state is AuthInitial || state is AuthLoading) return;
      final pending = state is AuthSyncConflictPending;
      if (pending == conflictPending) return;
      conflictPending = pending;
      widget.onAuthChanged();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
