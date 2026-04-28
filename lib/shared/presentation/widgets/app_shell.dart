import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_event.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_action_card.dart';
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

  static const _labels = [
    'Home',
    'Activity',
    'Category',
    'Trends',
    'Scan',
    'Budgets',
  ];

  bool get _showFab => _currentIndex <= 2; // Home, Activity, or Category

  IconData _navIcon(int i, {bool fill = false}) {
    final s = fill ? PhosphorIconsStyle.fill : PhosphorIconsStyle.light;
    switch (i) {
      case 0:
        return PhosphorIcons.house(s);
      case 1:
        return PhosphorIcons.listDashes(s);
      case 2:
        return PhosphorIcons.tag(s);
      case 3:
        return PhosphorIcons.chartBar(s);
      case 4:
        return PhosphorIcons.listMagnifyingGlass(s);
      case 5:
        return PhosphorIcons.wallet(s);
      default:
        return PhosphorIcons.circle(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          BlocProvider(
            create: (_) => di.getIt<DashboardBloc>(),
            child: const DashboardPage(),
          ),
          const RecordListPage(),
          const CategoryListPage(),
          const ReportsPage(),
          _ScanPageWithFab(),
          const BudgetListPage(),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context),
              shape: const CircleBorder(),
              child: Icon(
                _currentIndex == 2
                    ? PhosphorIcons.listPlus(PhosphorIconsStyle.bold)
                    : PhosphorIcons.plus(PhosphorIconsStyle.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(colors),
    );
  }

  Widget _buildBottomNav(ColorScheme colors) {
    // Items after index 2 are rendered on the right of the FAB
    final leftCount = 3;
    final rightCount = 3;

    return Container(
      height: 80,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Home, Activity, Budgets
          ...List.generate(leftCount, (i) => _navItem(i, colors)),
          // FAB spacer — animated width for smooth transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _showFab ? 56 : 0,
          ),
          // Right side: Trends, Scan, Profile
          ...List.generate(rightCount, (i) => _navItem(leftCount + i, colors)),
        ],
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
    if (_currentIndex == 2) {
      _showCategoryTypeSelection(context);
    } else {
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

  void _showCategoryTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(context).colorScheme;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppActionCard(
                        icon: PhosphorIcons.trendDown(PhosphorIconsStyle.fill),
                        label: 'Expense Category',
                        color: colors.error,
                        onTap: () {
                          Navigator.pop(ctx);
                          _navigateToCategoryForm(context, RecordType.expense);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppActionCard(
                        icon: PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
                        label: 'Income Category',
                        color: colors.primary,
                        onTap: () {
                          Navigator.pop(ctx);
                          _navigateToCategoryForm(context, RecordType.income);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToCategoryForm(BuildContext context, RecordType type) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: CategoryFormPage(category: null, initialType: type),
        ),
      ),
    );
  }
}

// ──────────────────────────────────
// Scan Page with FAB
// ──────────────────────────────────
class _ScanPageWithFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SmsPermissionGate(child: ContactSelectorPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScanOptions(context),
        child: Icon(PhosphorIcons.fileMagnifyingGlass(PhosphorIconsStyle.bold)),
      ),
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
                leading: Icon(
                  PhosphorIcons.clockCounterClockwise(
                    PhosphorIconsStyle.regular,
                  ),
                ),
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
                leading: Icon(
                  PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                ),
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
                leading: Icon(
                  PhosphorIcons.calendarDots(PhosphorIconsStyle.regular),
                ),
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
                leading: Icon(
                  PhosphorIcons.infinity(PhosphorIconsStyle.regular),
                ),
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
