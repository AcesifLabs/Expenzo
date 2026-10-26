import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const fontFamily = 'Lato';

  static const fontFamilyFallback = ['NotoSansBengali'];

  static const tabularFigures = [FontFeature.tabularFigures()];

  static final TextStyle displayLarge = _bold.copyWith(
    fontSize: 32,
    height: 1.2,
  );
  static final TextStyle displayMedium = displayLarge;
  static final TextStyle displaySmall = displayLarge;
  static final TextStyle headlineLarge = displayLarge;
  static final TextStyle headlineMedium = _bold.copyWith(
    fontSize: 24,
    height: 1.25,
  );
  static final TextStyle headlineSmall = headlineMedium;
  static final TextStyle titleLarge = _bold.copyWith(fontSize: 18, height: 1.3);
  static final TextStyle titleMedium = _bold.copyWith(
    fontSize: 16,
    height: 1.4,
  );
  static final TextStyle titleSmall = _bold.copyWith(fontSize: 14, height: 1.4);
  static final TextStyle bodyLarge = _regular.copyWith(
    fontSize: 16,
    height: 1.5,
  );
  static final TextStyle bodyMedium = _regular.copyWith(
    fontSize: 14,
    height: 1.45,
  );
  static final TextStyle bodySmall = _regular.copyWith(
    fontSize: 12,
    height: 1.4,
  );
  static final TextStyle labelLarge = _bold.copyWith(fontSize: 14);
  static final TextStyle labelMedium = _bold.copyWith(fontSize: 12);
  static final TextStyle labelSmall = _regular.copyWith(
    fontSize: 12,
    letterSpacing: 0.2,
  );

  static final TextStyle currency = _bold.copyWith(
    fontSize: 18,
    fontFeatures: tabularFigures,
  );

  static const _regular = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w400,
  );
  static const _bold = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontWeight: FontWeight.w700,
  );
}
