import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/utils/navigation_utils.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_list_page.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/expense_form_page.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          const ExpenseListPage(),
          const CategoryListPage(),
          const SmsPermissionGate(child: ContactSelectorPage()),
          BlocProvider(
            create: (_) => di.getIt<SettingsBloc>(),
            child: const SettingsPage(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        shape: const CircleBorder(),
        child: Icon(PhosphorIcons.plus(PhosphorIconsStyle.regular)),
      ),
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
              'Expenses',
            ),
            _buildNavItem(
              1,
              PhosphorIcons.tag(PhosphorIconsStyle.regular),
              PhosphorIcons.tag(PhosphorIconsStyle.fill),
              'Categories',
            ),
            const SizedBox(width: 40), // Space for FAB
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

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      SlidePageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: di.getIt<ExpenseBloc>()),
            BlocProvider.value(value: di.getIt<CategoryBloc>()),
          ],
          child: const ExpenseFormPage(expense: null),
        ),
      ),
    );
  }
}
