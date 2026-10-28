import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'app_icons.dart';

class CategoryTile extends StatelessWidget {
  final String colorHex;

  final String iconKey;
  final double size;

  const CategoryTile({
    super.key,
    required this.colorHex,
    required this.iconKey,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ColorUtils.fromHex(
      colorHex,
      fallback: ColorUtils.fromHex(CategoryPalette.slate.hex),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tile,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Icon(
        AppIcons.getCategoryIcon(iconKey),
        size: size * 0.5,
        color: CategoryPalette.iconOn(tile),
      ),
    );
  }
}
