import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class CategoryTypeToggle extends StatelessWidget {
  final RecordType type;
  final ValueChanged<RecordType> onSwitch;

  const CategoryTypeToggle({
    super.key,
    required this.type,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == RecordType.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Expense',
              isActive: isExpense,
              activeColor: _DesignTokens.expenseColor,
              activeFill: _DesignTokens.expenseFill,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              onTap: () => onSwitch(RecordType.expense),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Income',
              isActive: !isExpense,
              activeColor: _DesignTokens.incomeColor,
              activeFill: _DesignTokens.incomeFill,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
              onTap: () => onSwitch(RecordType.income),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color activeFill;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.activeFill,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isActive ? activeFill : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? activeColor : _DesignTokens.mutedColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignTokens {
  static const Color expenseColor = Color(0xFFF48FB1);
  static const Color expenseFill = Color(0x20F48FB1);
  static const Color incomeColor = Color(0xFFA2D3A4);
  static const Color incomeFill = Color(0x20A2D3A4);
  static const Color mutedColor = Color(0xFF8E8E93);

  _DesignTokens._();
}
