import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/models/sms_scan_range_selection.dart';
import 'package:expense_tracker/features/sms_parser/presentation/widgets/sms_scan_options_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/shared/presentation/widgets/sms_permission_gate.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import 'lazy_indexed_stack.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  DateTime? _lastFabPress;

  static const _labels = ['Home', 'Activity', 'Scan', 'Budgets'];

  IconData _navIcon(int i, {bool fill = false}) {
    if (fill) {
      switch (i) {
        case 0:
          return PiconsFill.house;
        case 1:
          return PiconsFill.listDashes;
        case 2:
          return PiconsFill.chat;
        case 3:
          return PiconsFill.wallet;
        default:
          return PiconsFill.circle;
      }
    }
    switch (i) {
      case 0:
        return PiconsLight.house;
      case 1:
        return PiconsLight.listDashes;
      case 2:
        return PiconsLight.chat;
      case 3:
        return PiconsLight.wallet;
      default:
        return PiconsLight.circle;
    }
  }

  Widget _navIconTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(scale: animation, child: child);
  }

  Widget _buildBottomNav(ColorScheme colors, bool showFab) {
    const leftCount = 2;
    const rightCount = 2;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: colors.surface.withAlpha(240),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: colors.onSurface.withAlpha(10), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ...List.generate(leftCount, (i) => _navItem(i, colors)),
                AnimatedContainer(
                  duration: AppSpacing.durationNormal,
                  curve: Curves.easeInOut,
                  width: showFab ? 48 : 0,
                ),
                ...List.generate(
                  rightCount,
                  (i) => _navItem(leftCount + i, colors),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, ColorScheme colors) {
    final sel = _currentIndex == i;
    final mutedColor = colors.onSurface.withAlpha(120);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppSpacing.durationFast,
                transitionBuilder: _navIconTransition,
                child: Icon(
                  _navIcon(i, fill: sel),
                  key: ValueKey('nav_icon_${i}_$sel'),
                  color: sel ? colors.primary : mutedColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppSpacing.durationFast,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  color: sel ? colors.primary : mutedColor,
                ),
                child: Text(_labels[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchToTab(int index) {
    if (!mounted || _currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _onFabPressed(BuildContext context) {
    final now = DateTime.now();
    final lastPress = _lastFabPress;
    if (lastPress != null &&
        now.difference(lastPress) < const Duration(seconds: 1)) {
      return;
    }
    _lastFabPress = now;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RecordBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: const NewTransactionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final showFab = _currentIndex <= 1 && !keyboardOpen;

    return Scaffold(
      extendBody: true,
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(onNavigateToTab: _switchToTab),
          const RecordListPage(),
          _ScanPageWithFab(),
          const BudgetListPage(),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              heroTag: 'shell_fab',
              onPressed: () => _onFabPressed(context),
              shape: const CircleBorder(),
              child: Icon(PiconsBold.plus),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(colors, showFab),
    );
  }
}

class _ScanPageWithFab extends StatefulWidget {
  const _ScanPageWithFab();

  @override
  State<_ScanPageWithFab> createState() => _ScanPageWithFabState();
}

class _ScanPageWithFabState extends State<_ScanPageWithFab>
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

    setState(() {
      _hasSmsPermission = status.isGranted;
    });
  }

  void _onPermissionChanged(bool granted) {
    if (!mounted || _hasSmsPermission == granted) {
      return;
    }
    setState(() {
      _hasSmsPermission = granted;
    });
  }

  Future<void> _showScanOptions(BuildContext context) async {
    final selection = await showModalBottomSheet<SmsScanRangeSelection>(
      context: context,
      backgroundColor: const Color(0x00000000),
      builder: (_) => SmsScanOptionsSheet(now: DateTime.now()),
    );
    if (!context.mounted || selection == null) {
      return;
    }

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

    // The outer AppShell Scaffold consumes viewInsets for its body, so reading
    // MediaQuery here would always report 0. Read the true keyboard inset from
    // the platform view instead.
    final bottomInset = WidgetsBinding
        .instance
        .platformDispatcher
        .views
        .first
        .viewInsets
        .bottom;
    final keyboardOpen = bottomInset > 0;

    if (!mounted || _keyboardOpen == keyboardOpen) {
      return;
    }

    setState(() {
      _keyboardOpen = keyboardOpen;
    });
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
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                heroTag: 'scan_fab',
                onPressed: () => _showScanOptions(context),
                child: Icon(PiconsBold.scan),
              ),
            )
          : null,
    );
  }
}

bool shouldShowScanFab({
  required bool hasSmsPermission,
  required bool keyboardOpen,
}) => hasSmsPermission && !keyboardOpen;
