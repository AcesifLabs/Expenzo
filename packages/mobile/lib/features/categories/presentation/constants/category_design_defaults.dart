import 'package:flutter/material.dart';

/// Default icon colors for built-in categories, matching the .pen design.
class CategoryDesignDefaults {
  CategoryDesignDefaults._();

  // ── Design System Colors ──────────────────────────────────────────────

  /// Primary lavender color.
  static const Color primaryColor = Color(0xFFD1C4E9);

  /// Expense accent color (pink).
  static const Color expenseColor = Color(0xFFF48FB1);

  /// Income accent color (green).
  static const Color incomeColor = Color(0xFFA2D3A4);

  /// Muted text color.
  static const Color mutedColor = Color(0xFF8E8E93);

  // ── Color Picker Options ──────────────────────────────────────────────

  /// Available colors for the color picker in the category form.
  static const List<String> colorOptions = [
    '#D1C4E9', // Lavender
    '#F48FB1', // Pink
    '#A2D3A4', // Green
    '#90CAF9', // Blue
    '#FFD700', // Gold
    '#FF8A65', // Orange
  ];

  // ── Icon Grid Options ─────────────────────────────────────────────────

  /// Available icons for the icon grid in the category form.
  static const List<String> iconOptions = [
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

  // ── Category Name Mappings ────────────────────────────────────────────

  /// Maps category names to their design-specific icon colors.
  static const Map<String, Color> iconColors = {
    'General': Color(0xFF8E8E93),
    'Food & Dining': Color(0xFFF48FB1),
    'Transport': Color(0xFF90CAF9),
    'Shopping': Color(0xFFD1C4E9),
    'Bills & Utilities': Color(0xFFFFD700),
    'Entertainment': Color(0xFFA2D3A4),
    'Health': Color(0xFFF48FB1),
    'Education': Color(0xFF90CAF9),
    'Salary': Color(0xFFA2D3A4),
    'Freelance': Color(0xFFD1C4E9),
    'Investment': Color(0xFF90CAF9),
  };

  /// Maps category names to their Phosphor icon names (matching emoji field).
  static const Map<String, String> iconNames = {
    'General': 'tag',
    'Food & Dining': 'forkKnife',
    'Transport': 'car',
    'Shopping': 'bag',
    'Bills & Utilities': 'lightning',
    'Entertainment': 'ticket',
    'Health': 'heartbeat',
    'Education': 'bookOpen',
    'Salary': 'currencyDollar',
    'Freelance': 'briefcase',
    'Investment': 'trendUp',
  };

  /// Default color for categories without a specific design color.
  static const Color defaultColor = Color(0xFF8E8E93);

  /// Gets the icon color for a category by name.
  static Color getColor(String categoryName) {
    return iconColors[categoryName] ?? defaultColor;
  }

  /// Gets the icon name for a category by name.
  static String getIconName(String categoryName) {
    return iconNames[categoryName] ?? 'tag';
  }
}
