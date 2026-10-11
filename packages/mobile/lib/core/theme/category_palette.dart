import 'package:flutter/material.dart';

/// A category color the user can pick.
class CategoryColor {
  final String name;

  /// Stored on the category as `#RRGGBB`.
  final String hex;

  const CategoryColor(this.name, this.hex);
}

/// Category colors (DESIGN.md, "Category palette").
///
/// Categories render as a pastel tile behind an icon. These are data colors:
/// they stay the same in light and dark mode.
abstract final class CategoryPalette {
  static const lavender = CategoryColor('Lavender', '#D1C4E9');
  static const rose = CategoryColor('Rose', '#F8BBD0');
  static const mint = CategoryColor('Mint', '#C8E6C9');
  static const sky = CategoryColor('Sky', '#BBDEFB');
  static const amber = CategoryColor('Amber', '#FFE0B2');
  static const teal = CategoryColor('Teal', '#B2DFDB');
  static const peach = CategoryColor('Peach', '#FFCCBC');
  static const slate = CategoryColor('Slate', '#CFD8DC');

  static const all = [lavender, rose, mint, sky, amber, teal, peach, slate];

  /// Colors for the seeded default categories, by category id.
  static final seedColors = <String, String>{
    'default_in_salary': mint.hex,
    'default_in_freelance': lavender.hex,
    'default_in_investment': sky.hex,
    'default_in_refund': peach.hex,
    'default_in_gift': rose.hex,
    'default_in_general': slate.hex,
    'default_out_food': peach.hex,
    'default_out_shopping': lavender.hex,
    'default_out_transport': sky.hex,
    'default_out_home': teal.hex,
    'default_out_health': rose.hex,
    'default_out_entertainment': amber.hex,
    'default_out_bills': mint.hex,
    'default_out_travel': sky.hex,
    'default_out_education': lavender.hex,
    'default_out_investment': teal.hex,
    'default_out_gifts': amber.hex,
    'default_out_general': slate.hex,
  };

  /// Seed colors before schema v17. Migration v17 only recolors a default
  /// category whose color still equals this value; it is also the rollback
  /// mapping if the recolor ever has to be undone.
  static const legacySeedColors = <String, String>{
    'default_in_salary': '#A2D3A4',
    'default_in_freelance': '#D1C4E9',
    'default_in_investment': '#90CAF9',
    'default_in_refund': '#FF9800',
    'default_in_gift': '#FFB300',
    'default_in_general': '#8E8E93',
    'default_out_food': '#F48FB1',
    'default_out_shopping': '#D1C4E9',
    'default_out_transport': '#90CAF9',
    'default_out_home': '#5E35B1',
    'default_out_health': '#F48FB1',
    'default_out_entertainment': '#A2D3A4',
    'default_out_bills': '#FFD700',
    'default_out_travel': '#3949AB',
    'default_out_education': '#90CAF9',
    'default_out_investment': '#90CAF9',
    'default_out_gifts': '#FFB300',
    'default_out_general': '#8E8E93',
  };

  /// Dark icon on light tiles, white icon on dark ones, so colors users
  /// picked before v17 (some are saturated) stay readable.
  static Color iconOn(Color tile) {
    return tile.computeLuminance() > 0.4
        ? const Color(0xFF1C1C1E)
        : Colors.white;
  }
}
