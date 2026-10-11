import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/sms_parser/application/realtime_sms_processor.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class SmsPermissionGate extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool>? onPermissionChanged;

  const SmsPermissionGate({
    super.key,
    required this.child,
    this.onPermissionChanged,
  });

  @override
  State<SmsPermissionGate> createState() => _SmsPermissionGateState();
}

class _SmsPermissionGateState extends State<SmsPermissionGate> {
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.sms.status;
    final hasPermission = status.isGranted;
    widget.onPermissionChanged?.call(hasPermission);
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }

    if (status.isGranted) {
      unawaited(_startRealtimeProcessor());
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    final status = await Permission.sms.request();
    final hasPermission = status.isGranted;
    widget.onPermissionChanged?.call(hasPermission);
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }

    if (status.isGranted) {
      unawaited(_startRealtimeProcessor());
    }

    if (!status.isGranted && status.isPermanentlyDenied && mounted) {
      showDialog(
        context: context,
        builder: (_) => const _PermissionRequiredDialog(),
      );
    }
  }

  Future<void> _startRealtimeProcessor() async {
    try {
      await di.getIt<RealtimeSmsProcessor>().start();
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('SmsPermissionGate start skipped: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasPermission) {
      return widget.child;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PiconsRegular.warningCircle,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              t.common.smsGate.title,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.common.smsGate.body,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              icon: const Icon(PiconsRegular.check),
              label: Text(
                t.common.smsGate.allow,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
              onPressed: () => _requestPermission(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRequiredDialog extends StatelessWidget {
  const _PermissionRequiredDialog();

  void _openAppSettings() {
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.common.smsGate.deniedTitle),
      content: Text(t.common.smsGate.deniedBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.common.cancel),
        ),
        ElevatedButton(
          onPressed: _openAppSettings,
          child: Text(t.common.openSettings),
        ),
      ],
    );
  }
}
