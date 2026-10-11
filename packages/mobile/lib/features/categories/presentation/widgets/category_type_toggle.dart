import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

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
    final palette = context.palette;
    final isExpense = type == RecordType.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.smd,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: RecordType.expense.displayName,
              isActive: isExpense,
              activeColor: palette.expense,
              activeFill: palette.expense.withAlpha(0x20),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusControl),
              ),
              onTap: () => onSwitch(RecordType.expense),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: RecordType.income.displayName,
              isActive: !isExpense,
              activeColor: palette.income,
              activeFill: palette.income.withAlpha(0x20),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppSpacing.radiusControl),
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
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isActive ? activeFill : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isActive ? activeColor : palette.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
