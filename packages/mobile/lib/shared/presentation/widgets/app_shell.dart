import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_page.dart';
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
          BlocProvider(
            create: (_) => di.getIt<DashboardBloc>(),
            child: const DashboardPage(),
          ),
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

  Widget _buildBottomNav(ColorScheme colors, bool showFab) {
    final leftCount = 2;
    final rightCount = 2;

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
                color: Colors.black.withAlpha(20),
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
                  duration: const Duration(milliseconds: 300),
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
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  _navIcon(i, fill: sel),
                  key: ValueKey('nav_icon_${i}_$sel'),
                  color: sel ? colors.primary : colors.onSurface.withAlpha(120),
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  color: sel ? colors.primary : colors.onSurface.withAlpha(120),
                ),
                child: Text(_labels[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFabPressed(BuildContext context) {
    final now = DateTime.now();
    if (_lastFabPress != null &&
        now.difference(_lastFabPress!) < const Duration(seconds: 1)) {
      return;
    }
    _lastFabPress = now;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<RecordBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: const NewTransactionSheet(),
      ),
    );
  }
}

class _ScanPageWithFab extends StatefulWidget {
  @override
  State<_ScanPageWithFab> createState() => _ScanPageWithFabState();
}

class _ScanPageWithFabState extends State<_ScanPageWithFab> {
  bool _hasSmsPermission = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmsPermissionGate(
        onPermissionChanged: _onPermissionChanged,
        child: const ContactSelectorPage(),
      ),
      floatingActionButton: _hasSmsPermission
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton(
                heroTag: 'scan_fab',
                onPressed: () => _showScanOptions(context),
                child: Icon(PiconsBold.scan),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  void _showScanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Scan past SMS for records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(PiconsRegular.clockCounterClockwise),
                title: const Text('Last 7 Days'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 7)),
                  );
                },
              ),
              ListTile(
                leading: Icon(PiconsRegular.calendar),
                title: const Text('Last 30 Days'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 30)),
                  );
                },
              ),
              ListTile(
                leading: Icon(PiconsRegular.calendarDots),
                title: const Text('Last 3 Months'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(
                    context,
                    DateTime.now().subtract(const Duration(days: 90)),
                  );
                },
              ),
              ListTile(
                leading: Icon(PiconsRegular.infinity),
                title: const Text('All Time'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _startScan(context, DateTime(2000));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startScan(BuildContext context, DateTime since) {
    final smsBloc = di.getIt<SmsScannerBloc>();
    smsBloc.add(StartScan(since: since, filterDuplicates: true));
    Navigator.of(context).push(
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: smsBloc,
          child: const SmsScanResultsPage(),
        ),
      ),
    );
  }
}
