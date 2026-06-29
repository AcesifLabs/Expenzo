import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

class CategoryPickerItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final Color errorBorderColor;
  final Color selectedColor;
  final VoidCallback onTap;

  const CategoryPickerItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.errorBorderColor,
    this.selectedColor = const Color(0xFFD1C4E9),
    required this.onTap,
  });

  Color _resolveTextColor(Color iconColor, bool isLight) {
    return (isSelected && isLight) ? Colors.black : iconColor;
  }

  Color _resolveBorderColor(ColorScheme colors) {
    if (isSelected) return selectedColor.withAlpha(50);
    if (errorBorderColor != Colors.transparent) return errorBorderColor;

    return colors.onSurface.withAlpha(40);
  }

  Color _iconColor(ColorScheme colors) {
    return isSelected ? selectedColor : colors.onSurface.withAlpha(150);
  }

  Widget _label() {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: isSelected
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconColor = _iconColor(colors);
    // ignore: unused_local_variable
    final textColor = _resolveTextColor(iconColor, isLight);
    final borderColor = _resolveBorderColor(colors);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withAlpha(25)
              : colors.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.getCategoryIcon(category.emoji),
              size: 20,
              color: iconColor,
            ),
            _label(),
          ],
        ),
      ),
    );
  }
}
