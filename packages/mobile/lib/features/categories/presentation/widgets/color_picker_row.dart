import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class ColorPickerRow extends StatelessWidget {
  final String selectedColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerRow({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
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
            t.categories.form.color,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: palette.textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Wrap(
            children: [
              for (final option in CategoryPalette.all)
                _ColorSwatch(
                  option: option,
                  isSelected:
                      option.hex.toUpperCase() == selectedColor.toUpperCase(),
                  onTap: () => onColorSelected(option.hex),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final CategoryColor option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(option.hex);

    return Semantics(
      label: t.categories.colors[option.name] ?? option.name,
      selected: isSelected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: AppSpacing.minTapTarget / 2,
        child: SizedBox.square(
          dimension: AppSpacing.minTapTarget,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.palette.textPrimary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      PiconsRegular.check,
                      size: 16,
                      color: CategoryPalette.iconOn(color),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
