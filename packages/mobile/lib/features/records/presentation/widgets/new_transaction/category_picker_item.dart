import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

class CategoryPickerItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const CategoryPickerItem({
    super.key,
    required this.category,
    required this.isSelected,
    this.selectedColor = const Color(0xFFD1C4E9),
    required this.onTap,
  });

  Color _iconColor(ColorScheme colors) {
    return isSelected ? selectedColor : colors.onSurface.withAlpha(150);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconColor = _iconColor(colors);
    final textColor = isSelected
        ? selectedColor
        : colors.onSurface.withAlpha(150);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: category.name,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? selectedColor.withAlpha(25)
                    : colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? selectedColor
                      : colors.outlineVariant.withAlpha(32),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    AppIcons.getCategoryIcon(category.emoji),
                    size: 16,
                    color: iconColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: textColor,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
