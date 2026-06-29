import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _latoLight = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w300,
  );
  static const _latoMedium = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w500,
  );
  static const _latoBold = TextStyle(
    fontFamily: 'Lato',
    fontWeight: FontWeight.w700,
  );

  static TextStyle get displayLarge =>
      _latoBold.copyWith(fontSize: 57, height: 1.12);
  static TextStyle get displayMedium =>
      _latoBold.copyWith(fontSize: 45, height: 1.15);
  static TextStyle get displaySmall =>
      _latoBold.copyWith(fontSize: 36, height: 1.2);
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
