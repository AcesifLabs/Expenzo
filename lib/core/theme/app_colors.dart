import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Palette ──
  // Lavender - Primary accent color
  static const Color primary = Color(0xFFD1C4E9);
  // Mint - Secondary
  static const Color secondary = Color(0xFFA2D3A4);
  // Deep charcoal bg - modern & clean
  static const Color backgroundLight = Color(0xFFF5F7FA);
  // True charcoal bg for dark theme
  static const Color backgroundDark = Color(0xFF141315);

  // ── Surface Colors ──
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C1B1D);

  // ── Text Colors ──
  static const Color textPrimaryLight = Color(0xFF1C1C1E);
  static const Color textPrimaryDark = Color(0xFFF5F7FA);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // ── Semantic Colors ──
  static const Color error = Color(0xFFFF3B30);
  static const Color errorDark = Color(0xFFF48FB1); // Rose
  static const Color success = Color(0xFF34C759);
  static const Color successDark = Color(0xFFA2D3A4); // Mint
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningDark = Color(0xFFFFD60A);

  // ── Financial Colors ──
  static const Color income = Color(0xFF34C759);
  static const Color incomeDark = Color(0xFFA2D3A4);
  static const Color expense = Color(0xFFFF3B30);
  static const Color expenseDark = Color(0xFFF48FB1);

  // ── Category Colors (Modern Vibrancy) ──
  static const List<Color> categoryColors = [
    Color(0xFF02FF94), // Neon Mint
    Color(0xFF00D97E), // Deep Mint
    Color(0xFF007AFF), // Blue
    Color(0xFF5856D6), // Purple
    Color(0xFFFF9500), // Orange
    Color(0xFFFF2D55), // Pink
    Color(0xFF00C7BE), // Teal
    Color(0xFFAF52DE), // Magenta
    Color(0xFFFF6480), // Coral
    Color(0xFF36D1A0), // Mint
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFF8B7355), // Earth
  ];

  // ── Aliases for convenience ──
  static const Color primaryLight = backgroundLight;
  static const Color surface = surfaceLight;
  // Bright neon accent → dark text for contrast
  static const Color onPrimary = Color(0xFF1C1C1E);
  static const Color onSecondary = Color(0xFF1C1C1E);
}
