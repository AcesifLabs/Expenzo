import 'dart:async';

import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/sync/connectivity_service.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:flutter/material.dart';

/// Blocks [child] while the device has no network link, with a clear
/// offline message and Try again. Same shape as [SmsPermissionGate].
class OfflineGate extends StatefulWidget {
  final Widget child;

  /// Override for tests; defaults to [ConnectivityService.hasNetworkLink].
  final Future<bool> Function()? checkOnline;

  // Optional: production uses ConnectivityService from GetIt.
  // ignore: unnecessary-nullable
  const OfflineGate({super.key, required this.child, this.checkOnline});

  @override
  State<OfflineGate> createState() => _OfflineGateState();
}

class _OfflineGateState extends State<OfflineGate> {
  var _checking = true;
  var _online = false;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<bool> _probe() {
    final check = widget.checkOnline;
    if (check != null) return check();

    return di.getIt<ConnectivityService>().hasNetworkLink();
  }

  Future<void> _refresh() async {
    setState(() => _checking = true);
    final online = await _probe();
    if (!mounted) return;
    setState(() {
      _online = online;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_online) return widget.child;

    return AppErrorState(
      message: t.common.errors.network,
      onRetry: () => unawaited(_refresh()),
    );
  }
}
