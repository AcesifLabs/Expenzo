import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Choose Icon',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _DesignTokens.mutedColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? _DesignTokens.selectedFill
              : _DesignTokens.unselectedFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _DesignTokens.selectedStroke
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            AppIcons.getCategoryIcon(iconName),
            size: 22,
            color: isSelected
                ? _DesignTokens.selectedIconColor
                : _DesignTokens.unselectedIconColor,
          ),
        ),
      ),
    );
  }
}

class _DesignTokens {
  static const Color selectedFill = Color(0x20D1C4E9);
  static const Color selectedStroke = Color(0xFFD1C4E9);
  static const Color unselectedFill = Color(0xFF2B292C);
  static const Color selectedIconColor = Color(0xFFD1C4E9);
  static const Color unselectedIconColor = Color(0xFF8E8E93);
  static const Color mutedColor = Color(0xFF8E8E93);

  _DesignTokens._();
}
