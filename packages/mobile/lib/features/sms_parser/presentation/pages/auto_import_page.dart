import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_selection.dart';
import 'package:expense_tracker/features/sms_parser/presentation/widgets/sms_scan_options_sheet.dart';
import 'package:expense_tracker/shared/presentation/widgets/sms_permission_gate.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AutoImportPage extends StatefulWidget {
  const AutoImportPage({super.key});

  @override
  State<AutoImportPage> createState() => _AutoImportPageState();
}

class _AutoImportPageState extends State<AutoImportPage>
    with WidgetsBindingObserver {
  bool _hasSmsPermission = false;
  bool _keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadInitialPermission());
  }

  Future<void> _loadInitialPermission() async {
    final status = await Permission.sms.status;
    if (!mounted) return;

    setState(() => _hasSmsPermission = status.isGranted);
  }

  void _onPermissionChanged(bool granted) {
    if (!mounted || _hasSmsPermission == granted) return;

    setState(() => _hasSmsPermission = granted);
  }

  Future<void> _showScanOptions(BuildContext context) async {
    final selection = await showModalBottomSheet<SmsScanRangeSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SmsScanOptionsSheet(now: DateTime.now()),
    );
    if (!context.mounted || selection == null) return;

    _startScan(context, selection);
  }

  void _startScan(BuildContext context, SmsScanRangeSelection selection) {
    final smsBloc = di.getIt<SmsScannerBloc>();
    smsBloc.add(
      StartScan(
        startDate: selection.startDate,
        endDate: selection.endDate,
        filterDuplicates: true,
      ),
    );
    context.push('/scan-results', extra: <String, dynamic>{'smsBloc': smsBloc});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    final keyboardOpen = bottomInset > 0;
    if (!mounted || _keyboardOpen == keyboardOpen) return;

    setState(() => _keyboardOpen = keyboardOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmsPermissionGate(
        onPermissionChanged: _onPermissionChanged,
        child: const ContactSelectorPage(),
      ),
      floatingActionButton:
          shouldShowScanFab(
            hasSmsPermission: _hasSmsPermission,
            keyboardOpen: _keyboardOpen,
          )
          ? FloatingActionButton.extended(
              heroTag: 'scan_fab',
              onPressed: () => _showScanOptions(context),
              icon: const Icon(PiconsRegular.listMagnifyingGlass),
              label: Text(t.smsParser.autoImport.scanPast),
            )
          : null,
    );
  }
}

bool shouldShowScanFab({
  required bool hasSmsPermission,
  required bool keyboardOpen,
}) => hasSmsPermission && !keyboardOpen;
