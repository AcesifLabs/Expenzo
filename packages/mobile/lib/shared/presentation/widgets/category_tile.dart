import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'app_icons.dart';

/// A category's icon on its color tile (DESIGN.md, "Category palette").
///
/// The one way categories are drawn, so every list shows them the same.
class CategoryTile extends StatelessWidget {
  /// Stored category color, `#RRGGBB`.
  final String colorHex;

  /// Category icon key, see [AppIcons.getCategoryIcon].
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
