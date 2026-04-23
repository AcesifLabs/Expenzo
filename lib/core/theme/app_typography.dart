import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Lato for body text - Light 300 for normal, Regular 400 for emphasis
  // Using Google Fonts which automatically handles loading and caching
  static final _latoLight = GoogleFonts.lato(fontWeight: FontWeight.w300);
  static final _latoRegular = GoogleFonts.lato(fontWeight: FontWeight.w400);
  static final _latoMedium = GoogleFonts.lato(fontWeight: FontWeight.w500);
  static final _latoBold = GoogleFonts.lato(fontWeight: FontWeight.w700);

  // Headlines - Lato Bold
  static TextStyle get headlineLarge => _latoBold.copyWith(fontSize: 32);

  static TextStyle get headlineMedium => _latoBold.copyWith(fontSize: 28);

  static TextStyle get headlineSmall => _latoBold.copyWith(fontSize: 24);

  // Titles - Lato Bold
  static TextStyle get titleLarge => _latoBold.copyWith(fontSize: 22);

  static TextStyle get titleMedium => _latoBold.copyWith(fontSize: 16);

  static TextStyle get titleSmall => _latoBold.copyWith(fontSize: 14);

  // Body - Lato Light 300 for normal text
  static TextStyle get bodyLarge => _latoLight.copyWith(fontSize: 16);

  static TextStyle get bodyMedium => _latoLight.copyWith(fontSize: 14);

  static TextStyle get bodySmall => _latoLight.copyWith(fontSize: 12);

  // Labels - Lato Medium
  static TextStyle get labelLarge => _latoMedium.copyWith(fontSize: 14);

  static TextStyle get labelMedium => _latoMedium.copyWith(fontSize: 12);

  static TextStyle get labelSmall => _latoMedium.copyWith(fontSize: 11);

  // Currency - Bold for readability
  static TextStyle get currency => _latoBold.copyWith(
    fontSize: 18,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
