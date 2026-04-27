import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_form_page.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'lazy_indexed_stack.dart';
import 'sms_permission_gate.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  bool get _showFab => _currentIndex == 0 || _currentIndex == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          const RecordListPage(),
          const CategoryListPage(),
          const SmsPermissionGate(child: ContactSelectorPage()),
          BlocProvider(
            create: (_) => di.getIt<SettingsBloc>(),
            child: const SettingsPage(),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
              onPressed: () => _onFabPressed(context),
              shape: const CircleBorder(),
              child: Icon(
                _currentIndex == 1
                    ? PhosphorIcons.listPlus(PhosphorIconsStyle.regular)
                    : PhosphorIcons.plus(PhosphorIconsStyle.regular),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              PhosphorIcons.invoice(PhosphorIconsStyle.regular),
              PhosphorIcons.invoice(PhosphorIconsStyle.fill),
              'Records',
            ),
            _buildNavItem(
              1,
              PhosphorIcons.tag(PhosphorIconsStyle.regular),
              PhosphorIcons.tag(PhosphorIconsStyle.fill),
              'Categories',
            ),
            if (_showFab) const SizedBox(width: 40), // Space for FAB
            _buildNavItem(
              2,
              PhosphorIcons.listMagnifyingGlass(PhosphorIconsStyle.regular),
              PhosphorIcons.listMagnifyingGlass(PhosphorIconsStyle.fill),
              'Scan',
            ),
            _buildNavItem(
              3,
              PhosphorIcons.faders(PhosphorIconsStyle.regular),
              PhosphorIcons.faders(PhosphorIconsStyle.fill),
              'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : icon, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _onFabPressed(BuildContext context) {
    if (_currentIndex == 0) {
      _showRecordTypeSelection(context);
    } else if (_currentIndex == 1) {
      _showCategoryTypeSelection(context);
    }
  }

  void _showRecordTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    PhosphorIcons.trendUp(PhosphorIconsStyle.regular),
                    color: Colors.green,
                  ),
                  title: const Text('Add Income'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToRecordForm(context, RecordType.income);
                  },
                ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.trendDown(PhosphorIconsStyle.regular),
                    color: Colors.red,
                  ),
                  title: const Text('Add Expense'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToRecordForm(context, RecordType.expense);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    PhosphorIcons.tag(PhosphorIconsStyle.regular),
                    color: Colors.green,
                  ),
                  title: const Text('Add Income Category'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCategoryForm(context, RecordType.income);
                  },
                ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.tag(PhosphorIconsStyle.regular),
                    color: Colors.red,
                  ),
                  title: const Text('Add Expense Category'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCategoryForm(context, RecordType.expense);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToRecordForm(BuildContext context, RecordType type) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: di.getIt<RecordBloc>()),
            BlocProvider.value(value: di.getIt<CategoryBloc>()),
          ],
          child: RecordFormPage(record: null, initialType: type),
        ),
      ),
    );
  }

  void _navigateToCategoryForm(BuildContext context, RecordType type) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => BlocProvider.value(
          value: di.getIt<CategoryBloc>(),
          child: CategoryFormPage(category: null, initialType: type),
        ),
      ),
    );
  }
}
