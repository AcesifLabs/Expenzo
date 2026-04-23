import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Palette ──
  // Deep Sage - Primary brand color (buttons, FAB, links)
  static const Color primary = Color(0xFF5A7863);
  // Muted Sage - Secondary (chips, badges, accents)
  static const Color secondary = Color(0xFF90AB8B);
  // Pale Sage - Background for light theme
  static const Color backgroundLight = Color(0xFFEBF4DD);
  // Dark Blue-Grey - Background for dark theme
  static const Color backgroundDark = Color(0xFF3B4953);

  // ── Surface Colors ──
  static const Color surfaceLight = Color(0xFFFFFFFF);
  // Rich dark for dark theme surface (darker than background for layering)
  static const Color surfaceDark = Color(0xFF25343D);

  // ── Text Colors ──
  static const Color textPrimaryLight = Color(0xFF3B4953);
  static const Color textPrimaryDark = Color(0xFFEBF4DD);
  static const Color textSecondaryLight = Color(0xFF5A7863);
  static const Color textSecondaryDark = Color(0xFF90AB8B);

  // ── Semantic Colors ──
  // Error: Warm Red (financial alerts, overspending)
  static const Color error = Color(0xFFD9534F);
  static const Color errorDark = Color(0xFFE57373);
  // Success: Primary Sage (income, goals met)
  static const Color success = Color(0xFF5A7863);
  static const Color successDark = Color(0xFF90AB8B);
  // Warning: Orange/Amber (budget warnings, pending)
  static const Color warning = Color(0xFFF0B429);
  static const Color warningDark = Color(0xFFF0B429);

  // ── Financial Colors ──
  // Income: Primary Sage (positive amounts)
  static const Color income = Color(0xFF5A7863);
  static const Color incomeDark = Color(0xFF90AB8B);
  // Expense: Error Red (negative amounts)
  static const Color expense = Color(0xFFD9534F);
  static const Color expenseDark = Color(0xFFE57373);

  // ── Category Colors (Sage/Earth Tones) ──
  static const List<Color> categoryColors = [
    Color(0xFF5A7863), // Deep Sage
    Color(0xFF90AB8B), // Muted Sage
    Color(0xFFD4A574), // Warm Sand
    Color(0xFF8B7355), // Earth Brown
    Color(0xFF6B8E7A), // Soft Green
    Color(0xFFA8C4B8), // Light Sage
    Color(0xFFD9A86C), // Amber Gold
    Color(0xFF7A6B5A), // Taupe
    Color(0xFF5A6B7A), // Ocean Sage
    Color(0xFFB8A890), // Stone
    Color(0xFF8B9A6B), // Olive
    Color(0xFF6B7A8B), // Teal
  ];

  // ── Aliases for convenience ──
  static const Color primaryLight = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
}
