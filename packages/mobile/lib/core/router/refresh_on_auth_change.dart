import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

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

  void _subscribeIfEnabled() {
    if (!widget.enabled || _subscription != null) return;
    final authBloc = context.read<AuthBloc>();
    var conflictPending = authBloc.state is AuthSyncConflictPending;
    _subscription = authBloc.stream.listen((state) {
      if (state is AuthInitial || state is AuthLoading) return;
      final pending = state is AuthSyncConflictPending;
      if (pending == conflictPending) return;
      conflictPending = pending;
      widget.onAuthChanged();
    });
  }

  @override
  void didUpdateWidget(RefreshOnAuthChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subscribeIfEnabled();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
