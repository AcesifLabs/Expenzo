import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

class TypeToggle extends StatelessWidget {
  final RecordType type;
  final ValueChanged<RecordType> onSwitch;

  const TypeToggle({super.key, required this.type, required this.onSwitch});

  Widget _buildPill(
    double pillLeft,
    double pillWidth,
    Duration animDuration,
    bool isExpense,
  ) {
    const expenseColor = AppColors.expense;
    const incomeColor = AppColors.success;

    return AnimatedPositioned(
      duration: animDuration,
      curve: Curves.easeInOut,
      left: pillLeft,
      top: 4,
      bottom: 4,
      child: AnimatedContainer(
        duration: animDuration,
        curve: Curves.easeInOut,
        width: pillWidth,
        decoration: BoxDecoration(
          color: (isExpense ? expenseColor : incomeColor).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = type == RecordType.expense;
    const animDuration = Duration(milliseconds: 500);

    return Container(
      decoration: BoxDecoration(
        color: colors.onSurface.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = constraints.maxWidth / 2 - 8;
          final pillLeft = isExpense ? 4.0 : constraints.maxWidth / 2;

          return SizedBox(
            height: 44,
            child: Stack(
              children: [
                _buildPill(pillLeft, pillWidth, animDuration, isExpense),
                Row(
                  children: [
                    Expanded(
                      child: _ToggleTab(
                        icon: PiconsFill.trendDown,
                        label: 'Expense',
                        isActive: isExpense,
                        activeColor: AppColors.expense,
                        colors: colors,
                        onTap: () => onSwitch(RecordType.expense),
                      ),
                    ),
                    Expanded(
                      child: _ToggleTab(
                        icon: PiconsFill.trendUp,
                        label: 'Income',
                        isActive: !isExpense,
                        activeColor: AppColors.success,
                        colors: colors,
                        onTap: () => onSwitch(RecordType.income),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isActive ? activeColor : colors.onSurface.withAlpha(100);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
