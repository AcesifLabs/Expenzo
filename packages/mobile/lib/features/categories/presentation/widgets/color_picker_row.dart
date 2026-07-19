import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class ColorPickerRow extends StatelessWidget {
  static const List<String> colorOptions = [
    '#D1C4E9',
    '#F48FB1',
    '#A2D3A4',
    '#90CAF9',
    '#FFD700',
    '#FF8A65',
  ];

  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  Color _parseColor(String hex) {
    final sanitized = hex.replaceFirst('#', '');

    return Color(int.parse('0xFF$sanitized'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'Choose Color',
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
          child: Row(
            children: colorOptions.map((hex) {
              final isSelected = hex == selectedColor;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _ColorSwatch(
                  color: _parseColor(hex),
                  isSelected: isSelected,
                  onTap: () => onColorSelected(hex),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? _DesignTokens.selectedBorder
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  PiconsRegular.check,
                  size: 16,
                  color: _DesignTokens.checkColor,
                ),
              )
            : null,
      ),
    );
  }
}

class _DesignTokens {
  static const Color selectedBorder = Color(0xFFF5F7FA);
  static const Color checkColor = Color(0xFF141315);
  static const Color mutedColor = Color(0xFF8E8E93);

  _DesignTokens._();
}
