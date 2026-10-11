import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class IconGridPicker extends StatelessWidget {
  static const List<String> iconNames = [
    'shoppingCart',
    'forkKnife',
    'car',
    'bag',
    'heart',
    'bookOpen',
    'filmStrip',
    'lightning',
    'coffee',
    'gift',
    'dog',
    'airplane',
  ];

  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  const IconGridPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.md),
          child: Text(
            t.categories.form.icon,
            style: AppTypography.bodySmall.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: iconNames.map((name) {
              return _IconCell(
                iconName: name,
                isSelected: name == selectedIcon,
                onTap: () => onIconSelected(name),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconCell({
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Semantics(
      button: true,
      selected: isSelected,
      label: t.categories.iconLabel(
        name: t.categories.icons[iconName] ?? iconName,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          decoration: BoxDecoration(
            color: isSelected
                ? palette.brand.withAlpha(0x20)
                : palette.surfaceHigh,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(
              color: isSelected ? palette.brand : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              AppIcons.getCategoryIcon(iconName),
              size: 22,
              color: isSelected ? palette.brand : palette.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
