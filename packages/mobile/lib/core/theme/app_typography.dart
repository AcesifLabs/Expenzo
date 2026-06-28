import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static final _latoLight = GoogleFonts.lato(fontWeight: FontWeight.w300);
  static final _latoMedium = GoogleFonts.lato(fontWeight: FontWeight.w500);
  static final _latoBold = GoogleFonts.lato(fontWeight: FontWeight.w700);

  static TextStyle get headlineLarge =>
      _latoBold.copyWith(fontSize: 32, height: 1.2);

  static TextStyle get headlineMedium =>
      _latoBold.copyWith(fontSize: 28, height: 1.2);

  static TextStyle get headlineSmall =>
      _latoBold.copyWith(fontSize: 24, height: 1.2);

  static TextStyle get titleLarge =>
      _latoBold.copyWith(fontSize: 22, height: 1.3);

  static TextStyle get titleMedium =>
      _latoBold.copyWith(fontSize: 16, height: 1.4);

  static TextStyle get titleSmall =>
      _latoBold.copyWith(fontSize: 14, height: 1.4);

  static TextStyle get bodyLarge =>
      _latoLight.copyWith(fontSize: 16, height: 1.6);

  static TextStyle get bodyMedium =>
      _latoLight.copyWith(fontSize: 14, height: 1.6);

  static TextStyle get bodySmall =>
      _latoLight.copyWith(fontSize: 12, height: 1.6);

  static TextStyle get labelLarge => _latoMedium.copyWith(fontSize: 14);

  static TextStyle get labelMedium => _latoMedium.copyWith(fontSize: 12);

  static TextStyle get labelSmall => _latoMedium.copyWith(fontSize: 11);

  static TextStyle get currency => _latoBold.copyWith(
    fontSize: 18,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
