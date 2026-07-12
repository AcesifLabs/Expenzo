import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:flutter/material.dart';

class TypeToggle extends StatelessWidget {
  final RecordType type;
  final ValueChanged<RecordType> onSwitch;

  const TypeToggle({super.key, required this.type, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isExpense = type == RecordType.expense;
    final expenseColor = colors.error;
    final incomeColor = colors.primary;

    return Semantics(
      container: true,
      label: 'Transaction type',
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: Row(
          children: [
            Expanded(
              child: _ToggleTab(
                label: 'Expense',
                isActive: isExpense,
                activeColor: expenseColor,
                colors: colors,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                onTap: () => onSwitch(RecordType.expense),
              ),
            ),
            Expanded(
              child: _ToggleTab(
                label: 'Income',
                isActive: !isExpense,
                activeColor: incomeColor,
                colors: colors,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                onTap: () => onSwitch(RecordType.income),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final ColorScheme colors;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.colors,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isActive ? activeColor : colors.onSurface.withAlpha(120);

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: isActive,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withAlpha(32) : Colors.transparent,
              borderRadius: borderRadius,
            ),
            child: Center(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: fgColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
